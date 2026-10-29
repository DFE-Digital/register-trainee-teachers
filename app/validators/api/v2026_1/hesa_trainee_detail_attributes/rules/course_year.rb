# frozen_string_literal: true

module Api
  module V20261
    class HesaTraineeDetailAttributes
      module Rules
        # Routes funded per training year (EYTDA) need the trainee's year of
        # training, as it decides which year's grant applies.
        class CourseYear < Api::Rules::Base
          attr_reader :hesa_trainee_detail_attributes

          delegate :course_year,
                   :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_route, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return ValidationResult.new(true) if skip_validation?
            return ValidationResult.new(true) if course_year.to_s.match?(/\A\d+\z/) && course_year.to_i.between?(1, training_years)

            ValidationResult.new(false, :training_year_invalid, { training_years: })
          end

        private

          def skip_validation?
            course_year.blank? || !yearly_route?
          end

          def yearly_route?
            training_route.is_a?(String) && ::Funding::AmountMatrix::YEARLY_ROUTES.key?(training_route)
          end

          def training_years
            ::Funding::AmountMatrix::YEARLY_ROUTES.fetch(training_route)
          end
        end
      end
    end
  end
end
