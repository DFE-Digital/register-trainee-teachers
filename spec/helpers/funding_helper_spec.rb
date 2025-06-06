# frozen_string_literal: true

require "rails_helper"

describe FundingHelper do
  include FundingHelper

  describe "#training_initiative_options" do
    context "when recruitment_cycle_year is 2024" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
      end

      it "returns initiatives from TRAINING_INITIATIVES_2024_TO_2025" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
        ].sort

        expect(training_initiative_options).to eq(expected_initiatives)
      end
    end

    context "when recruitment_cycle_year is 2025" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025)
      end

      it "returns initiatives from TRAINING_INITIATIVES_2025_TO_2026" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
          primary_mathematics_specialist
        ].sort

        expect(training_initiative_options).to eq(expected_initiatives)
      end
    end
  end

  describe "#available_training_initiatives_for_cycle" do
    context "when recruitment_cycle_year is 2024" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
      end

      it "returns TRAINING_INITIATIVES_2024_TO_2025" do
        expect(available_training_initiatives_for_cycle).to eq(TRAINING_INITIATIVES_2024_TO_2025)
      end
    end

    context "when recruitment_cycle_year is 2025" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2025)
      end

      it "returns TRAINING_INITIATIVES_2025_TO_2026" do
        expect(available_training_initiatives_for_cycle).to eq(TRAINING_INITIATIVES_2025_TO_2026)
      end
    end

    context "when a constant doesn't exist for the current recruitment cycle year" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2026)

        # Allow const_defined? to be called with any arguments but return false for all year constants
        allow(Object).to receive(:const_defined?).and_call_original
        allow(Object).to receive(:const_defined?).with("TRAINING_INITIATIVES_2026_TO_2027").and_return(false)
        allow(Object).to receive(:const_defined?).with("TRAINING_INITIATIVES_2025_TO_2026").and_return(false)
        allow(Object).to receive(:const_defined?).with("TRAINING_INITIATIVES_2024_TO_2025").and_return(false)
      end

      it "raises an error" do
        expect {
          available_training_initiatives_for_cycle
        }.to raise_error("No training initiatives found for any academic year between 2024 and 2026")
      end
    end
  end
end
