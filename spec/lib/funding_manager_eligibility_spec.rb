# frozen_string_literal: true

require "rails_helper"

describe FundingManager do
  # The current year's funding is signed off, as it will be by the time trainees start.
  let(:current_cycle) { (AcademicCycle.current || create(:academic_cycle, :current)).tap { |cycle| cycle.update!(published: true) } }
  let(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::MATHEMATICS) }
  let(:trainee) do
    build(:trainee, training_route: route, course_allocation_subject: allocation_subject, start_academic_cycle: cycle,
                    funding_eligibility: funding_eligibility)
  end
  let(:route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
  let(:cycle) { current_cycle }
  let(:funding_eligibility) { nil }
  let(:funding_manager) { described_class.new(trainee) }

  def add_funding(route, funding_type, amount, academic_cycle: cycle, training_year: nil)
    funding_method = create(:funding_method, training_route: route, funding_type: funding_type, amount: amount,
                                             academic_cycle: academic_cycle, training_year: training_year)
    create(:funding_method_subject, funding_method:, allocation_subject:)
  end

  context "without the funding eligibility step" do
    let(:funding_eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

    before { add_funding(route, FUNDING_TYPE_ENUMS[:bursary], 20_000) }

    it "works as before: the eligibility answer doesn't stop funding" do
      expect(funding_manager.eligibility_step?).to be(false)
      expect(funding_manager.funding_open?).to be(true)
      expect(funding_manager.can_apply_for_bursary?).to be(true)
    end
  end

  context "with the funding eligibility step", feature_funding_eligibility_step: true do
    before { add_funding(route, FUNDING_TYPE_ENUMS[:bursary], 20_000) }

    it "asks the bursary and scholarship question for a funded fee-funded route" do
      expect(funding_manager.eligibility_content_key).to eq(:bursary_scholarship)
      expect(funding_manager.can_apply_for_bursary?).to be(true)
    end

    context "when the trainee isn't eligible" do
      let(:funding_eligibility) { FUNDING_ELIGIBILITIES[:not_eligible] }

      it "offers no funding" do
        expect(funding_manager.funding_open?).to be(false)
        expect(funding_manager.can_apply_for_bursary?).to be(false)
      end
    end

    context "when the year's funding isn't signed off" do
      let(:cycle) { create(:academic_cycle, next_cycle: true) }

      before { add_funding(route, FUNDING_TYPE_ENUMS[:bursary], 30_000, academic_cycle: cycle) }

      it "shows the not signed off state and offers no funding" do
        expect(cycle.start_year).to be >= described_class::FUNDING_MANAGEMENT_START_YEAR
        expect(funding_manager.eligibility_content_key).to eq(:not_signed_off)
        expect(funding_manager.eligibility_informational?).to be(true)
        expect(funding_manager.can_apply_for_bursary?).to be(false)
      end

      context "when draft amounts can be used for internal testing", feature_funding_draft_amounts_in_journey: true do
        it "uses the draft amounts, flagged as not signed off" do
          expect(funding_manager.funding_signed_off?).to be(false)
          expect(funding_manager.using_draft_amounts?).to be(true)
          expect(funding_manager.eligibility_content_key).to eq(:bursary_scholarship)
          expect(funding_manager.can_apply_for_bursary?).to be(true)
          expect(funding_manager.bursary_amount).to be_present
        end
      end

      it "is still not released once signed off but before the start date" do
        cycle.update!(published: true)
        expect(funding_manager.funding_signed_off?).to be(false)
      end

      it "is released once signed off and started" do
        cycle.update!(published: true)
        Timecop.travel(cycle.start_date + 1.day) do
          expect(described_class.new(trainee).funding_signed_off?).to be(true)
          expect(described_class.new(trainee).can_apply_for_bursary?).to be(true)
        end
      end
    end

    context "when the route is EYTDA" do
      let(:route) { TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship] }

      before { add_funding(route, FUNDING_TYPE_ENUMS[:grant], 16_500, training_year: 1) }

      it "asks the training grant question for the training years" do
        # EYTDA funding is managed from 2026 to 2027, so it needs signing off from then.
        cycle.update!(published: true)

        expect(described_class.new(trainee).eligibility_content_key).to eq(:training_grant_by_year)
      end

      it "waits for the year's EYTDA funding to be signed off" do
        cycle.update!(published: false)

        expect(funding_manager.eligibility_content_key).to eq(:not_signed_off)
      end
    end

    context "when the route is Teacher degree apprenticeship" do
      let(:route) { TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship] }
      # The pilot grant is for trainees starting before 2027 to 2028.
      let(:cycle) do
        AcademicCycle.for_year(2026) || create(:academic_cycle, start_date: Date.new(2026, 8, 1), end_date: Date.new(2027, 7, 31))
      end

      it "asks the grant question for mathematics before 2027 to 2028 (the pilot)" do
        expect(cycle.start_year).to be < described_class::FUNDING_MANAGEMENT_START_YEAR
        expect(funding_manager.eligibility_content_key).to eq(:grant)
      end
    end

    context "when the route is Early years salaried with the combined grant" do
      let(:route) { TRAINING_ROUTE_ENUMS[:early_years_salaried] }

      before { add_funding(route, FUNDING_TYPE_ENUMS[:grant], 16_535) }

      it "shows the training grant and employer incentive" do
        expect(funding_manager.eligibility_content_key).to eq(:training_grant)
        expect(funding_manager.early_years_salaried_grant?).to be(true)
      end
    end

    context "when the route has no funding" do
      let(:route) { TRAINING_ROUTE_ENUMS[:assessment_only] }

      it "shows no funding information" do
        expect(funding_manager.eligibility_content_key).to eq(:no_funding)
        expect(funding_manager.no_funding?).to be(true)
      end
    end
  end
end
