# frozen_string_literal: true

require "rails_helper"

module Wizards
  describe AddFundingWizard do
    let(:plp) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    let(:plu) { TRAINING_ROUTE_ENUMS[:provider_led_undergrad] }

    describe "step order" do
      it "asks for training routes straight after funding method, then the Financial Incentive criteria and education phase" do
        expect(described_class::STEPS.each_cons(2)).to include(%w[funding_method training_routes], %w[training_routes financial_incentives], %w[financial_incentives education_phase])
      end

      it "no longer has the separate related_degree / disadvantaged_school steps" do
        expect(described_class::STEPS).not_to include("related_degree", "disadvantaged_school")
      end

      it "does not ask a QTS requirement question (award type is derived from routes)" do
        expect(described_class::STEPS).not_to include("qts_requirement")
      end

      it "places the student finance exception after training routes" do
        expect(described_class::STEPS.index("exception")).to be > described_class::STEPS.index("training_routes")
      end

      it "asks for the subjects before the amount, so the amount is the last question" do
        expect(described_class::STEPS.last(2)).to eq(%w[subjects amount])
      end
    end

    describe "Early years tiered bursary" do
      # The controller sets the route when the tiered bursary is chosen.
      let(:tiered) do
        { "funding_type" => "bursary", "academic_year" => "2027", "funding_method" => "early_years_tiered",
          "training_routes" => [TRAINING_ROUTE_ENUMS[:early_years_postgrad]] }
      end

      it "skips the training routes, Financial Incentive criteria and education phase steps" do
        expect(described_class.new("academic_year", draft: tiered).applicable_steps).not_to include("training_routes", "financial_incentives", "education_phase")
      end

      it "goes from funding method straight to amount, as the subject is set for early years" do
        create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT)

        expect(described_class.new("funding_method", draft: tiered).next_step).to eq("amount")
      end

      it "still asks those steps for other funding methods" do
        expect(described_class.new("academic_year", draft: tiered.merge("funding_method" => "D", "training_routes" => nil)).applicable_steps)
          .to include("training_routes", "financial_incentives", "education_phase")
      end

      it "sets the route to Early years postgraduate and the criteria to Neither" do
        expect(described_class.early_years_tiered_answers).to eq(
          "financial_incentives" => "neither",
          "training_routes" => [TRAINING_ROUTE_ENUMS[:early_years_postgrad]],
        )
      end
    end

    describe "early years routes" do
      let(:draft) { { "funding_type" => "grant", "academic_year" => "2027", "funding_method" => "E" } }

      it "skip the Financial Incentive criteria and education phase steps" do
        create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT)
        early_years = draft.merge("training_routes" => [TRAINING_ROUTE_ENUMS[:early_years_salaried]])

        expect(described_class.new("training_routes", draft: early_years).next_step).to eq("amount")
        expect(described_class.early_years_route_answers).to eq("financial_incentives" => "neither", "education_phase" => "not_applicable")
      end

      it "are asked for other routes" do
        other = draft.merge("training_routes" => [TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship]])

        expect(described_class.new("training_routes", draft: other).next_step).to eq("financial_incentives")
      end
    end

    describe "subjects for early years routes" do
      let(:draft) { { "funding_type" => "grant", "academic_year" => "2027", "funding_method" => "E" } }

      before { create(:allocation_subject, name: AllocationSubjects::EARLY_YEARS_ITT) }

      it "skips the subjects step, so amount is the last step" do
        early_years = draft.merge("training_routes" => [TRAINING_ROUTE_ENUMS[:early_years_salaried]])

        expect(described_class.new("amount", draft: early_years).next_step).to eq(described_class::CHECK_ANSWERS)
        expect(described_class.last_applicable_step(early_years)).to eq("amount")
      end

      it "keeps the subjects step for other routes, before the amount" do
        other = draft.merge("training_routes" => [TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship]])

        expect(described_class.new("education_phase", draft: other).next_step).to eq("subjects")
        expect(described_class.new("subjects", draft: other).next_step).to eq("amount")
        expect(described_class.last_applicable_step(other)).to eq("amount")
      end
    end

    describe "student finance exception applicability" do
      def draft(overrides = {})
        { "funding_type" => "bursary", "academic_year" => "2026", "training_routes" => [plp] }.merge(overrides)
      end

      it "applies for a postgraduate bursary before 2027/28" do
        expect(described_class.applicable_step?("exception", draft)).to be(true)
      end

      it "applies for a postgraduate scholarship before 2027/28" do
        expect(described_class.applicable_step?("exception", draft("funding_type" => "scholarship"))).to be(true)
      end

      it "does not apply from 2027/28 onwards" do
        expect(described_class.applicable_step?("exception", draft("academic_year" => "2027"))).to be(false)
      end

      it "does not apply to grant funding" do
        expect(described_class.applicable_step?("exception", draft("funding_type" => "grant"))).to be(false)
      end

      it "does not apply when only undergraduate routes are selected" do
        expect(described_class.applicable_step?("exception", draft("training_routes" => [plu]))).to be(false)
      end
    end

    describe "navigation skips a non-applicable exception step" do
      it "skips the exception step after education phase when it does not apply" do
        draft = { "funding_type" => "bursary", "academic_year" => "2027", "training_routes" => [plp] }
        wizard = described_class.new("education_phase", draft:)
        expect(wizard.next_step).to eq("subjects")
      end

      it "walks into the exception step after education phase when it applies" do
        draft = { "funding_type" => "bursary", "academic_year" => "2026", "training_routes" => [plp] }
        wizard = described_class.new("education_phase", draft:)
        expect(wizard.next_step).to eq("exception")
      end
    end

    describe "funding method (bursary type)" do
      it "is asked only for a bursary" do
        expect(described_class.applicable_step?("funding_method", { "funding_type" => "bursary" })).to be(true)
        expect(described_class.applicable_step?("funding_method", { "funding_type" => "grant" })).to be(false)
        expect(described_class.applicable_step?("funding_method", { "funding_type" => "scholarship" })).to be(false)
      end

      it "sets the only method for grants and scholarships" do
        expect(described_class.funding_method_answers("grant")).to eq("funding_method" => "E")
        expect(described_class.funding_method_answers("scholarship")).to eq("funding_method" => "4")
        expect(described_class.funding_method_answers("bursary")).to be_nil
      end
    end
  end
end
