# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:mathematics_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Mathematics" } }
  let(:trainee) { create(:trainee, training_route: route, course_allocation_subject: mathematics, start_academic_cycle: cycle) }

  subject(:prerequisites) { described_class.new(trainee.reload).funding_prerequisites }

  def add_funding(degree_relevance: nil, school_disadvantage: nil, funding_type: FUNDING_TYPE_ENUMS[:bursary])
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: 20_000,
                                             academic_cycle: cycle, degree_relevance: degree_relevance, school_disadvantage: school_disadvantage)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
  end

  before { enable_features(:funding_eligibility_step) }

  describe "#funding_prerequisites" do
    context "when the funding is split by degree relevance" do
      before do
        add_funding(degree_relevance: :relevant)
        add_funding(degree_relevance: :unrelated)
      end

      it "needs the degree when there isn't one" do
        expect(prerequisites).to eq([:degree])
      end

      it "needs nothing once a degree with a subject is added" do
        create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: mathematics_degree.id, subject: mathematics_degree.name)

        expect(prerequisites).to eq([])
      end

      context "on an undergraduate route" do
        let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }

        it "never needs a degree" do
          expect(prerequisites).to eq([])
        end
      end

      it "needs nothing without the funding eligibility step" do
        disable_features(:funding_eligibility_step)

        expect(prerequisites).to eq([])
      end
    end

    context "when the funding is split by the employing school's designation" do
      let(:route) { TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] }

      before do
        add_funding(school_disadvantage: :disadvantaged, funding_type: FUNDING_TYPE_ENUMS[:grant])
        add_funding(school_disadvantage: :non_disadvantaged, funding_type: FUNDING_TYPE_ENUMS[:grant])
        create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: mathematics_degree.id, subject: mathematics_degree.name)
      end

      it "needs the employing school when there isn't one" do
        expect(prerequisites).to eq([:employing_school])
      end

      it "needs it when the employing school is not applicable" do
        trainee.update!(employing_school_not_applicable: true)

        expect(prerequisites).to eq([:employing_school])
      end

      it "needs nothing once the employing school is recorded" do
        trainee.update!(employing_school: create(:school))

        expect(prerequisites).to eq([])
      end
    end

    context "when the funding is split by both and neither is entered" do
      let(:route) { TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] }

      before do
        add_funding(degree_relevance: :relevant, funding_type: FUNDING_TYPE_ENUMS[:grant])
        add_funding(school_disadvantage: :disadvantaged, funding_type: FUNDING_TYPE_ENUMS[:grant])
      end

      it "needs the degree first, then the employing school" do
        expect(prerequisites).to eq(%i[degree employing_school])
      end
    end

    context "when the funding isn't split" do
      before { add_funding }

      it "needs nothing" do
        expect(prerequisites).to eq([])
      end
    end

    context "when another subject's funding is split" do
      before do
        other = create(:funding_method, training_route: route, academic_cycle: cycle, degree_relevance: :relevant)
        create(:funding_method_subject, funding_method: other, allocation_subject: create(:allocation_subject, name: AllocationSubjects::PHYSICS))
      end

      it "needs nothing" do
        expect(prerequisites).to eq([])
      end
    end
  end
end
