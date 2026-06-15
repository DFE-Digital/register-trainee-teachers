# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::HesaTraineeDetailAttributes::Rules::CourseAgeRange do
  subject { described_class }

  let(:trainee_attributes) do
    Api::V20261::TraineeAttributes.new(training_route:)
  end
  let(:hesa_trainee_detail_attributes) do
    Api::V20261::HesaTraineeDetailAttributes.new(
      { course_age_range:, trainee_attributes: },
      record_source: "api",
    )
  end

  describe ".call" do
    context "when the `course_age_range` is blank" do
      let(:course_age_range) { nil }
      let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_postgrad] }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end
    end

    context "when the `training_route` is blank" do
      let(:course_age_range) { "13920" }
      let(:training_route) { nil }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end
    end

    context "when the `training_route` is an early years route" do
      let(:training_route) { TRAINING_ROUTE_ENUMS[:early_years_postgrad] }

      context "with the early years `course_age_range`" do
        let(:course_age_range) { "13920" }

        it "returns true" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
        end
      end

      context "with a non early years `course_age_range`" do
        let(:course_age_range) { "13918" }

        it "returns false with an `early_years_invalid` error" do
          result = subject.call(hesa_trainee_detail_attributes)

          expect(result.valid?).to be(false)
          expect(result.error_type).to eq(:early_years_invalid)
        end
      end
    end

    context "when the `training_route` is not an early years route" do
      let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }

      context "with the early years `course_age_range`" do
        let(:course_age_range) { "13920" }

        it "returns false with a `reserved_for_early_years` error" do
          result = subject.call(hesa_trainee_detail_attributes)

          expect(result.valid?).to be(false)
          expect(result.error_type).to eq(:reserved_for_early_years)
        end
      end

      context "with a non early years `course_age_range`" do
        let(:course_age_range) { "13918" }

        it "returns true" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
        end
      end
    end
  end
end
