# frozen_string_literal: true

require "rails_helper"

describe FundingHelper do
  include FundingHelper

  describe "#training_initiative_options" do
    let(:academic_cycle) { create(:academic_cycle, start_date: Date.new(year, 8, 1), end_date: Date.new(year + 1, 7, 31)) }
    let(:trainee) { create(:trainee, itt_start_date: Date.new(year, 9, 1), start_academic_cycle: academic_cycle) }

    context "when looking for 2022 initiatives" do
      let(:year) { 2022 }

      it "returns 2022-2023 initiatives" do
        expected_initiatives = %w[
          future_teaching_scholars
          maths_physics_chairs_programme_researchers_in_schools
          now_teach
          transition_to_teach
          troops_to_teachers
          veterans_teaching_undergraduate_bursary
        ]
        expect(training_initiative_options(trainee)).to match_array(expected_initiatives)
      end
    end

    context "when looking for 2023 initiatives" do
      let(:year) { 2023 }

      it "returns 2023-2024 initiatives" do
        expected_initiatives = %w[
          future_teaching_scholars
          international_relocation_payment
          now_teach
          transition_to_teach
          veterans_teaching_undergraduate_bursary
        ]
        expect(training_initiative_options(trainee)).to match_array(expected_initiatives)
      end
    end

    context "when looking for 2024 initiatives" do
      let(:year) { 2024 }

      it "returns 2024-2025 initiatives" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
        ]
        expect(training_initiative_options(trainee)).to match_array(expected_initiatives)
      end
    end

    context "when looking for 2025 initiatives" do
      let(:year) { 2025 }

      it "returns 2025-2026 initiatives" do
        expected_initiatives = %w[
          international_relocation_payment
          now_teach
          veterans_teaching_undergraduate_bursary
          primary_mathematics_specialist
        ]
        expect(training_initiative_options(trainee)).to match_array(expected_initiatives)
      end
    end

    context "when constant doesn't exist for the year" do
      let(:year) { 1999 }

      it "returns an empty array" do
        expect(training_initiative_options(trainee)).to be_empty
      end
    end
  end
end
