# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/SpecFilePathFormat
RSpec.describe Api::V20250Rc::HesaTraineeDetailAttributes::Rules::FundingMethod do
  subject { described_class }

  around do |example|
    Timecop.freeze(Date.new(2025, 5, 1)) { example.run }
  end

  let!(:current_academic_cycle) { create(:academic_cycle, cycle_year: 2024) }
  let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2025) }

  let(:course_subject_one) { "mathematics" }
  let(:training_route) { :provider_led_postgrad }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }
  let(:trainee_start_date) { Date.new(2025, 10, 1).iso8601 }
  let(:trainee_attributes) do
    Api::V20250Rc::TraineeAttributes.new(
      training_route:,
      course_subject_one:,
      trainee_start_date:,
    )
  end
  let(:hesa_trainee_detail_attributes) do
    Api::V20250Rc::HesaTraineeDetailAttributes.new(
      { trainee_attributes:, fund_code:, funding_method: },
      record_source: "api",
    )
  end

  describe ".call" do
    context "when the fund_code is NOT eligible and funding_method is blank" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
      let(:funding_method) { nil }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when the fund_code is NOT eligible and funding_method is NONE" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }
      let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }

      it "returns true" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
      end

      it "returns no error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
      end
    end

    context "when the fund_code is NOT eligible and funding_method is set" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }

      it "returns false" do
        expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
      end

      it "returns error details" do
        expect(subject.call(hesa_trainee_detail_attributes).error_details).to eq(
          {
            academic_cycle: "2025 to 2026",
            funding_type: "bursary",
            training_route: "provider_led_postgrad",
            subject: "mathematics",
          },
        )
      end
    end

    context "when the fund_code is eligible" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }

      context "when there is no matching funding rule" do
        it "returns false" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
        end
      end

      context "when training_route is an InvalidValue" do
        let(:training_route) { Api::V20250Rc::HesaMapper::Attributes::InvalidValue.new("invalid_route") }

        it "returns false" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
        end
      end

      context "when funding_method is NONE" do
        let(:funding_method) { Hesa::CodeSets::BursaryLevels::NONE }

        it "returns true" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
        end

        it "returns no error details" do
          expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
        end
      end

      context "when funding_method is an invalid value" do
        let(:funding_method) { "not-a-funding-method" }

        it "returns true" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
        end

        it "returns no error details" do
          expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
        end
      end

      context "when there is a matching funding rule" do
        let(:allocation_subject) { create(:allocation_subject) }
        let!(:subject_specialism) do
          create(
            :subject_specialism,
            allocation_subject: allocation_subject,
            name: course_subject_one,
          )
        end
        let(:funding_rule) do
          create(
            :funding_method,
            training_route: :provider_led_postgrad,
            funding_type: :bursary,
            academic_cycle: academic_cycle,
          )
        end
        let!(:funding_method_subject) do
          create(
            :funding_method_subject,
            funding_method: funding_rule,
            allocation_subject: allocation_subject,
          )
        end

        it "returns true" do
          expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(true)
        end

        it "returns no error details" do
          expect(subject.call(hesa_trainee_detail_attributes).error_details).to be_nil
        end

        context "when the start date is invalid" do
          let(:trainee_start_date) { "not a date" }

          it "returns false after falling back to current cycle" do
            expect(subject.call(hesa_trainee_detail_attributes).valid?).to be(false)
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
