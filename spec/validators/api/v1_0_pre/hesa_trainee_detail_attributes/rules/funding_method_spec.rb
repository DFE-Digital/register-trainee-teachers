# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V10Pre::HesaTraineeDetailAttributes::Rules::FundingMethod do
  subject { described_class }

  let!(:academic_cycle) { create(:academic_cycle, :current) }

  let(:course_subject_one) { "mathematics" }
  let(:training_route) { :provider_led_postgrad }
  let(:funding_method) { Hesa::CodeSets::BursaryLevels::POSTGRADUATE_BURSARY }
  let(:trainee_attributes) do
    Api::V10Pre::TraineeAttributes.new(training_route:, course_subject_one:)
  end
  let(:hesa_trainee_detail_attributes) do
    Api::V10Pre::HesaTraineeDetailAttributes.new(
      { trainee_attributes:, fund_code:, funding_method: },
      record_source: "api",
    )
  end

  describe "::valid?" do
    context "when the fund_code is NOT eligible" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::NOT_ELIGIBLE }

      it "returns true" do
        expect(subject.valid?(hesa_trainee_detail_attributes)).to be(true)
      end
    end

    context "when the fund_code is eligible" do
      let(:fund_code) { Hesa::CodeSets::FundCodes::ELIGIBLE }

      context "when there is no matching funding rule" do
        it "returns false" do
          expect(subject.valid?(hesa_trainee_detail_attributes)).to be(false)
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
          expect(subject.valid?(hesa_trainee_detail_attributes)).to be(true)
        end
      end
    end
  end
end
