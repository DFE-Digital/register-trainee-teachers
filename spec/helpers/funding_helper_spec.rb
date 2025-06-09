# frozen_string_literal: true

require "rails_helper"

describe FundingHelper do
  include FundingHelper

  describe "#training_initiative_options" do
    it "returns sorted initiatives from available_training_initiatives_for_cycle" do
      academic_cycle = create(:academic_cycle, start_date: Date.new(2023, 8, 1), end_date: Date.new(2024, 7, 31))
      trainee = create(:trainee, itt_start_date: Date.new(2023, 9, 1), start_academic_cycle: academic_cycle)

      initiatives = %w[transition_to_teach now_teach future_teaching_scholars]

      # Only testing that it sorts the result from available_training_initiatives_for_cycle
      allow(self).to receive(:available_training_initiatives_for_cycle).with(trainee).and_return(initiatives)

      expect(training_initiative_options(trainee)).to eq(initiatives.sort)
    end
  end

  describe "#available_training_initiatives_for_cycle" do
    context "when no trainee is provided" do
      it "returns an empty array" do
        expect(available_training_initiatives_for_cycle).to eq([])
      end
    end

    context "when trainee without start_academic_cycle is provided" do
      let(:trainee) { create(:trainee, start_academic_cycle: nil) }

      it "returns an empty array" do
        expect(available_training_initiatives_for_cycle(trainee)).to eq([])
      end
    end
  end

  describe "#find_initiatives_for_year" do
    context "when looking for 2022 initiatives" do
      it "returns 2022-2023 initiatives" do
        expected_initiatives = %w[
          future_teaching_scholars
          maths_physics_chairs_programme_researchers_in_schools
          now_teach
          transition_to_teach
          troops_to_teachers
          veterans_teaching_undergraduate_bursary
        ]

        expect(find_initiatives_for_year(2022)).to eq(expected_initiatives)
      end
    end

    context "when looking for 2023 initiatives" do
      it "returns 2023-2024 initiatives" do
        expected_initiatives = %w[
          future_teaching_scholars
          international_relocation_payment
          now_teach
          transition_to_teach
          veterans_teaching_undergraduate_bursary
        ]

        expect(find_initiatives_for_year(2023)).to eq(expected_initiatives)
      end
    end

    context "when looking for 2024 initiatives" do
      it "returns 2024-2025 initiatives" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
        ]

        expect(find_initiatives_for_year(2024)).to eq(expected_initiatives)
      end
    end

    context "when looking for 2025 initiatives" do
      it "returns 2025-2026 initiatives" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
          primary_mathematics_specialist
        ]

        expect(find_initiatives_for_year(2025)).to eq(expected_initiatives)
      end
    end

    context "when constant doesn't exist for the year but exists for previous year" do
      it "returns initiatives from the most recent available year" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
          primary_mathematics_specialist
        ]

        # 2026 doesn't exist, should fall back to 2025
        expect(find_initiatives_for_year(2026)).to eq(expected_initiatives)
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
end
