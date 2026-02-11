# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/SpecFilePathFormat
RSpec.describe Api::V20260::HesaTraineeDetailAttributes::Rules::AdditionalTrainingInitiative do
  subject { described_class }

  it { is_expected.to be < Api::V20260::HesaTraineeDetailAttributes::Rules::TrainingInitiative }

  let(:year) { 2026 }
  let!(:current_academic_cycle) { create(:academic_cycle, cycle_year: year) }

  let(:trainee_attributes) do
    Api::V20260::TraineeAttributes.new(
      training_initiative: nil,
      trainee_start_date: Date.new(year, 12, 1).iso8601,
    )
  end
  let(:hesa_trainee_detail_attributes) do
    Api::V20260::HesaTraineeDetailAttributes.new(
      { additional_training_initiative:, trainee_attributes: },
      record_source: "api",
    )
  end

  around do |example|
    Timecop.freeze(Date.new(year, 5, 1)) { example.run }
  end

  describe ".call" do
    context "when `additional_training_initiative` is blank" do
      let(:additional_training_initiative) { "" }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end
    end

    context "when `additional_training_initiative` is nil" do
      let(:additional_training_initiative) { nil }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end
    end

    context "when `additional_training_initiative` is a valid HESA code and available in the given year" do
      let(:additional_training_initiative) { "036" }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when `additional_training_initiative` is a valid HESA code but not available in the given year" do
      let(:additional_training_initiative) { "025" }

      it "returns false" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
      end

      it "returns error details including the mapped value and academic cycle" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to eq(
          { academic_cycle: "2026 to 2027", additional_training_initiative: "transition_to_teach" },
        )
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
