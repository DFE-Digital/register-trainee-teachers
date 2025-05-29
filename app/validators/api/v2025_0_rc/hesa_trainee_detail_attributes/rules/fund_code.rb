# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailAttributes
      module Rules
        class FundCode < Api::Rules::Base
          include DateValidatable

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
            ::FundingMethod.where(
              academic_cycle_id: academic_cycle.id,
            ).pluck(:training_route).uniq
          end

          def academic_cycle
            @academic_cycle ||= start_date.present? ? AcademicCycle.for_date(start_date) : AcademicCycle.for_date(Time.zone.now + ::Trainees::SetAcademicCycles::DEFAULT_CYCLE_OFFSET)
          end

          def start_date
            value = trainee_attributes.trainee_start_date || trainee_attributes.itt_start_date
            if value.is_a?(String)
              value = valid_date_string?(value) ? Date.iso8601(value) : nil
            end
            value
          end
        end
      end
    end
  end
end
