# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/SpecFilePathFormat
RSpec.describe Api::V20250Rc::HesaTraineeDetailAttributes::Rules::TrainingInitiative do
  subject { described_class }

  around do |example|
    Timecop.freeze(Date.new(2025, 5, 1)) { example.run }
  end

  let!(:current_academic_cycle) { create(:academic_cycle, cycle_year: 2024) }
  let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2025) }

  let(:trainee_attributes) do
    Api::V20250Rc::TraineeAttributes.new(
      training_initiative:,
    )
  end
  let(:hesa_trainee_detail_attributes) do
    Api::V20250Rc::HesaTraineeDetailAttributes.new(
      { trainee_attributes: },
      record_source: "api",
    )
  end

  describe ".call" do
    context "when the `training_initiative` is nil" do
      let(:training_initiative) { nil }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when the `training_initiative` is an empty string" do
      let(:training_initiative) { "" }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when the `training_initiative` is a valid HESA code and available in the given year" do
      let(:training_initiative) { "" }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when the `training_initiative` is a valid HESA code but not available in the given year" do
      let(:training_initiative) { "" }

      it "returns false" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
      end

      it "returns error details including the given value and allowed values" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
