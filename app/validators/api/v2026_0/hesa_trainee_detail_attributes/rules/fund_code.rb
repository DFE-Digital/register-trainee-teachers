# frozen_string_literal: true

module Api
  module V20260
    class HesaTraineeDetailAttributes
      module Rules
        class FundCode < Api::Rules::Base
          include DateValidatable
          include Api::Rules::AcademicCyclable

          FUND_CODE       = "7"
          AGE_RANGE_CODES = DfE::ReferenceData::AgeRanges::HESA_CODE_SETS.keys.freeze

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

            training_route.in?(funded_training_routes) && course_age_range.in?(AGE_RANGE_CODES)
          end

        private

          def funded_training_routes
            return [] if academic_cycle.nil?

            ::FundingMethod.where(
              academic_cycle_id: academic_cycle.id,
            ).pluck(:training_route).uniq
          end
        end
      end
    end
  end
end
