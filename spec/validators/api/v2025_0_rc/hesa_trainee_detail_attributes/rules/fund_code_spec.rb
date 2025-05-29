# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/SpecFilePathFormat
RSpec.describe Api::V20250Rc::HesaTraineeDetailAttributes::Rules::FundCode do
  subject { described_class }

  let!(:current_academic_cycle) { create(:academic_cycle, cycle_year: 2024) }
  let!(:academic_cycle) { create(:academic_cycle, cycle_year: 2025) }
  let(:trainee_start_date) { Date.new(2025, 10, 1).iso8601 }

  let(:hesa_trainee_detail_attributes) do
    Api::V20250Rc::HesaTraineeDetailAttributes.new(
      { trainee_attributes:, fund_code:, course_age_range: },
      record_source: "api",
    )
  end
  let(:trainee_attributes) { Api::V20250Rc::TraineeAttributes.new(training_route:, trainee_start_date:) }

  before do
    %w[
      provider_led_postgrad
      provider_led_undergrad
      school_direct_tuition_fee
      school_direct_salaried
      opt_in_undergrad
    ].each do |training_route|
      create(
        :funding_method,
        training_route: training_route,
        funding_type: :bursary,
        academic_cycle: academic_cycle,
      )
    end
  end

  describe "::valid?" do
    context "when the fund_code != 7" do
      let(:fund_code) { "2" }
      let(:course_age_range) { nil }
      let(:training_route) { nil }

      it "returns true" do
        expect(subject.valid?(hesa_trainee_detail_attributes)).to be(true)
      end
    end

    context "with a fund_code == 7" do
      let(:fund_code) { "7" }

      DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.each_key do |course_age_range|
        context "when the age_range is #{course_age_range}" do
          let(:course_age_range) { course_age_range }

          %i[provider_led_postgrad provider_led_undergrad school_direct_tuition_fee school_direct_salaried].each do |training_route|
            let(:training_route) { TRAINING_ROUTE_ENUMS[training_route] }

            context "when the training_route is #{training_route}" do
              it "returns true" do
                expect(subject.valid?(hesa_trainee_detail_attributes)).to be(true)
              end
            end
          end

          context "when the training_route is invalid" do
            let(:training_route) { TRAINING_ROUTE_ENUMS[:hpitt_postgrad] }

            it "returns false" do
              expect(subject.valid?(hesa_trainee_detail_attributes)).to be(false)
            end
          end
        end
      end

      context "when the age_range is invalid" do
        let(:course_age_range) { "1234" }
        let(:training_route) { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }

        it "returns false" do
          expect(subject.valid?(hesa_trainee_detail_attributes)).to be(false)
        end
      end
    end
  end
end
# rubocop:enable RSpec/SpecFilePathFormat
