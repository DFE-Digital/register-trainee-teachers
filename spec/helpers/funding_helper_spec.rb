# frozen_string_literal: true

require "rails_helper"

describe FundingHelper do
  include FundingHelper

  describe "#training_initiative_options" do
    context "when no trainee is provided" do
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

    context "when trainee with start_academic_cycle 2023 is provided" do
      let(:cycle_2023) { create(:academic_cycle, start_date: Date.new(2023, 8, 1), end_date: Date.new(2024, 7, 31)) }
      let(:trainee) { create(:trainee, itt_start_date: Date.new(2023, 9, 1), start_academic_cycle: cycle_2023) }

      it "returns initiatives from TRAINING_INITIATIVES_2023_TO_2024" do
        expected_initiatives = %w[
          future_teaching_scholars
          international_relocation_payment
          now_teach
          transition_to_teach
          veterans_teaching_undergraduate_bursary
        ].sort

        expect(training_initiative_options(trainee)).to eq(expected_initiatives)
      end
    end

    context "when trainee with start_academic_cycle 2022 is provided" do
      let(:cycle_2022) { create(:academic_cycle, start_date: Date.new(2022, 8, 1), end_date: Date.new(2023, 7, 31)) }
      let(:trainee) { create(:trainee, itt_start_date: Date.new(2022, 9, 1), start_academic_cycle: cycle_2022) }

      it "returns initiatives from TRAINING_INITIATIVES_2022_TO_2023" do
        expected_initiatives = %w[
          future_teaching_scholars
          maths_physics_chairs_programme_researchers_in_schools
          now_teach
          transition_to_teach
          troops_to_teachers
          veterans_teaching_undergraduate_bursary
        ].sort

        expect(training_initiative_options(trainee)).to eq(expected_initiatives)
      end
    end
  end

  describe "#available_training_initiatives_for_cycle" do
    context "when no trainee is provided" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
      end

      it "returns TRAINING_INITIATIVES_2024_TO_2025" do
        expect(available_training_initiatives_for_cycle).to eq(TRAINING_INITIATIVES_2024_TO_2025)
      end
    end

    context "when trainee with start_academic_cycle 2023 is provided" do
      let(:cycle_2023) { create(:academic_cycle, start_date: Date.new(2023, 8, 1), end_date: Date.new(2024, 7, 31)) }
      let(:trainee) { create(:trainee, itt_start_date: Date.new(2023, 9, 1), start_academic_cycle: cycle_2023) }

      it "returns TRAINING_INITIATIVES_2023_TO_2024" do
        expect(available_training_initiatives_for_cycle(trainee)).to eq(TRAINING_INITIATIVES_2023_TO_2024)
      end
    end
  end

  describe "#find_initiatives_for_year" do
    context "when constant exists for the year" do
      it "returns the correct constant" do
        expect(find_initiatives_for_year(2023)).to eq(TRAINING_INITIATIVES_2023_TO_2024)
      end
    end

    context "when constant doesn't exist for the year but exists for previous year" do
      it "returns initiatives from the most recent available year" do
        # 2025 constant exists, but 2026 doesn't - should fall back to 2025
        allow(Object).to receive(:const_defined?).and_call_original
        allow(Object).to receive(:const_defined?).with("TRAINING_INITIATIVES_2026_TO_2027").and_return(false)
        
        expect(find_initiatives_for_year(2026)).to eq(TRAINING_INITIATIVES_2025_TO_2026)
      end
    end

    context "when no constants exist for any year" do
      before do
        allow(Object).to receive(:const_defined?).and_call_original
        allow(Object).to receive(:const_defined?).with(/TRAINING_INITIATIVES_/).and_return(false)
      end

      it "returns an empty array" do
        expect(find_initiatives_for_year(2026)).to eq([])
      end
    end
  end
  
  describe "#get_academic_year" do
    context "when trainee has a start_academic_cycle" do
      let(:cycle_2023) { create(:academic_cycle, start_date: Date.new(2023, 8, 1), end_date: Date.new(2024, 7, 31)) }
      let(:trainee) { create(:trainee, itt_start_date: Date.new(2023, 9, 1), start_academic_cycle: cycle_2023) }

      it "returns the start_year from the academic cycle" do
        expect(get_academic_year(trainee)).to eq(2023)
      end
    end

    context "when trainee has no start_academic_cycle" do
      let(:trainee) { create(:trainee, start_academic_cycle: nil) }

      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
      end

      it "returns the current recruitment cycle year from settings" do
        expect(get_academic_year(trainee)).to eq(2024)
      end
    end

    context "when no trainee is provided" do
      before do
        allow(Settings).to receive(:current_recruitment_cycle_year).and_return(2024)
      end

      it "returns the current recruitment cycle year from settings" do
        expect(get_academic_year(nil)).to eq(2024)
      end
    end
  end
end
