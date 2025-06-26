# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailAttributes
      module Rules
        class TrainingInitiative < Api::Rules::Base
          include DateValidatable
          include Api::Rules::AcademicCyclable

          attr_reader :hesa_trainee_detail_attributes

          delegate :additional_training_initiative,
            :trainee_attributes, to: :hesa_trainee_detail_attributes
          delegate :training_initiative, to: :trainee_attributes

          def initialize(hesa_trainee_detail_attributes)
            @hesa_trainee_detail_attributes = hesa_trainee_detail_attributes
          end

          def call
            return ValidationResult.new(true) if no_training_initiative?

            return ValidationResult.new(false, error_details) if training_initiative_not_eligible?

            ValidationResult.new(true)
          end

        private

          def training_initiative_not_eligible?
            !training_initiative_eligible?
          end

          def training_initiative_eligible?
            available_initiatives = Funding::AvailableTrainingInitiativesService.call(academic_cycle:)

            available_initiatives.include?(training_initiative)
          end

          def no_training_initiative?
            training_initiative.blank? ||
              training_initiative.to_s == "no_initiative" ||
              training_initiative == ROUTE_INITIATIVES_ENUMS[:no_initiative]
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
