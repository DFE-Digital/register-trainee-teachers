# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:mathematics) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:mathematics_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Mathematics" } }
  let(:astronomy_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Astronomy" } }
  let(:history_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "History" } }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:trainee) { create(:trainee, training_route: route, course_allocation_subject: mathematics, start_academic_cycle: cycle) }
  let(:funding_manager) { described_class.new(trainee.reload) }

  def add_degree(reference_subject)
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: reference_subject.id, subject: reference_subject.name)
  end

  def add_funding(amount, funding_type: FUNDING_TYPE_ENUMS[:bursary], degree_relevance: nil, school_disadvantage: nil)
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: amount, academic_cycle: cycle,
                                             degree_relevance: degree_relevance, school_disadvantage: school_disadvantage)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: mathematics)
  end

  before do
    enable_features(:funding_eligibility_step)
    create(:relevant_degree_mapping, academic_cycle: cycle, allocation_subject: mathematics, hecos_code: mathematics_degree.hecos_code)
  end

  describe "#degree_explanation" do
    context "when the funding is split by degree relevance" do
      before do
        add_funding(20_000, degree_relevance: :relevant)
        add_funding(10_000, degree_relevance: :unrelated)
      end

      it "names the relevant degree" do
        add_degree(astronomy_degree)
        add_degree(mathematics_degree)

        expect(funding_manager.degree_explanation).to eq(key: :relevant, degree: "Mathematics")
      end

      it "names the degree that isn't relevant" do
        add_degree(astronomy_degree)

        expect(funding_manager.degree_explanation).to eq(key: :not_relevant, degrees: %w[Astronomy])
        expect(funding_manager.bursary_amount).to eq(10_000)
      end

      it "names all the degrees when none is relevant" do
        add_degree(astronomy_degree)
        add_degree(history_degree)

        expect(funding_manager.degree_explanation).to eq(key: :not_relevant, degrees: %w[Astronomy History])
      end

      it "says nothing before a degree is added" do
        expect(funding_manager.degree_explanation).to be_nil
      end

      it "says nothing without the funding eligibility step" do
        disable_features(:funding_eligibility_step)
        add_degree(astronomy_degree)

        expect(funding_manager.degree_explanation).to be_nil
      end
    end

    it "says nothing when the funding isn't split by degree" do
      add_funding(20_000)
      add_degree(astronomy_degree)

      expect(funding_manager.degree_explanation).to be_nil
    end
  end

  describe "#employing_school_explanation and the amount" do
    let(:route) { TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] }
    let(:school) { create(:school, name: "Bluemeadow 2 High", urn: "254333") }

    before do
      add_funding(15_000, funding_type: FUNDING_TYPE_ENUMS[:grant], school_disadvantage: :disadvantaged)
      add_funding(5_000, funding_type: FUNDING_TYPE_ENUMS[:grant], school_disadvantage: :non_disadvantaged)
    end

    it "says the school is on the list, and gives its amount" do
      create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :disadvantaged)
      trainee.update!(employing_school: school)

      expect(funding_manager.employing_school_explanation).to eq(key: :listed, school: "Bluemeadow 2 High (URN 254333)")
      expect(funding_manager.grant_amount).to eq(15_000)
    end

    it "says the same for a special school" do
      create(:funding_school_designation, school: school, academic_cycle: cycle, designation: :special)
      trainee.update!(employing_school: school)

      expect(funding_manager.employing_school_explanation[:key]).to eq(:listed)
      expect(funding_manager.grant_amount).to eq(15_000)
    end

    it "says the school isn't on the list, and gives the lower amount" do
      trainee.update!(employing_school: school)

      expect(funding_manager.employing_school_explanation).to eq(key: :not_listed, school: "Bluemeadow 2 High (URN 254333)")
      expect(funding_manager.grant_amount).to eq(5_000)
    end

    it "doesn't count another year's list" do
      next_cycle = create(:academic_cycle, start_date: cycle.start_date + 1.year, end_date: cycle.end_date + 1.year)
      create(:funding_school_designation, school: school, academic_cycle: next_cycle, designation: :disadvantaged)
      trainee.update!(employing_school: school)

      expect(funding_manager.employing_school_explanation[:key]).to eq(:not_listed)
    end

    it "says nothing, and gives the higher amount, before the school is added" do
      expect(funding_manager.employing_school_explanation).to be_nil
      expect(funding_manager.grant_amount).to eq(15_000)
    end
  end
end
