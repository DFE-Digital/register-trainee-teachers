# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  let(:cycle) { AcademicCycle.current || create(:academic_cycle, :current) }
  let(:chemistry) { create(:allocation_subject, name: AllocationSubjects::CHEMISTRY) }
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:chemistry_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "Chemistry" } }
  let(:history_degree) { DfEReference::DegreesQuery::SUBJECTS.all.find { |s| s.name == "History" } }
  let(:trainee) { create(:trainee, training_route: route, course_allocation_subject: chemistry, start_academic_cycle: cycle) }
  let(:funding_manager) { described_class.new(trainee.reload) }

  def add_degree(reference_subject)
    create(:degree, :uk_degree_with_details, trainee: trainee, subject_uuid: reference_subject.id, subject: reference_subject.name)
  end

  def add_funding(funding_type, amount, degree_relevance: nil, availability: :available)
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: amount,
                                             academic_cycle: cycle, degree_relevance: degree_relevance, availability: availability)
    create(:funding_method_subject, funding_method: funding_method, allocation_subject: chemistry)
  end

  before do
    create(:relevant_degree_mapping, academic_cycle: cycle, allocation_subject: chemistry, hecos_code: chemistry_degree.hecos_code)
    add_funding(FUNDING_TYPE_ENUMS[:bursary], 29_000, degree_relevance: :relevant)
    add_funding(FUNDING_TYPE_ENUMS[:bursary], nil, degree_relevance: :unrelated, availability: :not_available)
  end

  context "with a relevant degree" do
    before { add_degree(chemistry_degree) }

    it "offers the relevant degree bursary" do
      expect(funding_manager.bursary_amount).to eq(29_000)
      expect(funding_manager.can_apply_for_bursary?).to be(true)
      expect(funding_manager.unavailable_for_degree_types).to be_empty
    end
  end

  context "with an unrelated degree" do
    before { add_degree(history_degree) }

    it "offers no bursary: it isn't available for an unrelated degree" do
      expect(funding_manager.bursary_amount).to be_nil
      expect(funding_manager.can_apply_for_bursary?).to be(false)
      expect(funding_manager.unavailable_for_degree_types).to eq(%w[bursary])
      expect(funding_manager.unrelated_degree_subject).to eq("History")
    end

    context "when there's also a scholarship for everyone" do
      before { add_funding(FUNDING_TYPE_ENUMS[:scholarship], 31_000) }

      it "still offers the scholarship" do
        expect(funding_manager.can_apply_for_scholarship?).to be(true)
        expect(funding_manager.scholarship_amount).to eq(31_000)
        expect(funding_manager.can_apply_for_bursary?).to be(false)
      end
    end
  end

  context "before a degree is entered" do
    it "shows the available amount as up to" do
      expect(funding_manager.bursary_amount).to eq(29_000)
      expect(funding_manager.unavailable_for_degree_types).to be_empty
    end
  end

  describe Funding::ClearUnavailableForDegree do
    it "clears a bursary choice when the degree becomes unrelated" do
      trainee.update!(applying_for_bursary: true, applying_for_scholarship: false, applying_for_grant: false)
      add_degree(history_degree)

      expect(described_class.call(trainee:)).to be(true)
      expect(trainee.reload.applying_for_bursary).to be_nil
      expect(trainee.progress.funding).to be(false)
    end

    it "keeps the choice when the degree is relevant" do
      trainee.update!(applying_for_bursary: true)
      add_degree(chemistry_degree)

      expect(described_class.call(trainee:)).to be(false)
      expect(trainee.reload.applying_for_bursary).to be(true)
    end
  end
end
