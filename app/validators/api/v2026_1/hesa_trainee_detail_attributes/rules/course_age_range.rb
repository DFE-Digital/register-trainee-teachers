# frozen_string_literal: true

module Api
  module V20261
    class HesaTraineeDetailAttributes
      module Rules
        class CourseAgeRange < Api::Rules::Base
          EARLY_YEARS_AGE_RANGE_CODE = ::ReferenceData::COURSE_AGE_RANGES.find(:zero_to_five).hesa_code.freeze

          attr_reader :hesa_trainee_detail_attributes

          delegate :course_age_range,
                   :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_route, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return ValidationResult.new(true) if skip_validation?

            if early_years_route?
              return ValidationResult.new(false, :early_years_invalid, {}) if course_age_range != EARLY_YEARS_AGE_RANGE_CODE
            elsif course_age_range == EARLY_YEARS_AGE_RANGE_CODE
              return ValidationResult.new(false, :reserved_for_early_years, {})
            end

            ValidationResult.new(true)
          end

        private

          def skip_validation?
            course_age_range.blank? ||
              training_route.blank? ||
              training_route.is_a?(Api::V20261::HesaMapper::Attributes::InvalidValue)
          end

          def early_years_route?
            EARLY_YEARS_TRAINING_ROUTES.include?(training_route)
          end
        end
      end
    end
  end
end
