# frozen_string_literal: true

module Api
  module V20260
    class HesaTraineeDetailAttributes
      module Rules
        class TrainingInitiative < Api::Rules::Base
          include DateValidatable
          include Api::Rules::AcademicCyclable

          attr_reader :hesa_trainee_detail_attributes

          delegate :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_initiative, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return ValidationResult.new(true) if skip_validation?

            return ValidationResult.new(false, :ineligible, error_details) if not_eligible?

            ValidationResult.new(true)
          end

        private

          def skip_validation?
            training_initiative.blank? ||
              training_initiative.to_s == "no_initiative" ||
              training_initiative == ROUTE_INITIATIVES_ENUMS[:no_initiative] ||
              training_initiative.is_a?(Api::V20260::HesaMapper::Attributes::InvalidValue)
          end

          def not_eligible?
            !available_initiatives.include?(validated_value)
          end

          def validated_value
            training_initiative
          end

          def available_initiatives
            @available_initiatives ||= Funding::AvailableTrainingInitiativesService.call(academic_cycle:)
          end

          def error_details
            {
              academic_cycle: academic_cycle&.label,
              training_initiative: training_initiative,
            }
          end
        end
      end
    end
  end
end
