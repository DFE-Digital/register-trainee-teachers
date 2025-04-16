# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes
      module Rules
        class FundCode < Api::Rules::Base
          FUND_CODE       = "7"
          AGE_RANGE_CODES = DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.keys.freeze
          TRAINING_ROUTES = %w[
            provider_led_postgrad
            provider_led_undergrad
            school_direct_tuition_fee
            school_direct_salaried
          ].freeze

          attr_reader :hesa_trainee_detail_attributes

          delegate :fund_code,
                   :course_age_range,
                   :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_route, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return true if fund_code != FUND_CODE || training_route.nil?

            training_route.in?(TRAINING_ROUTES) && course_age_range.in?(AGE_RANGE_CODES)
          end
        end
      end
    end
  end
end
