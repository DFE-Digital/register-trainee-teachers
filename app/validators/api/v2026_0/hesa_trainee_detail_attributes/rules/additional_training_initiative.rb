# frozen_string_literal: true

module Api
  module V20260
    class HesaTraineeDetailAttributes
      module Rules
        class AdditionalTrainingInitiative < TrainingInitiative
          delegate :additional_training_initiative, to: :hesa_trainee_detail_attributes

        private

          def skip_validation?
            additional_training_initiative.blank? || mapped_additional_training_initiative.nil?
          end

          def validated_value
            mapped_additional_training_initiative
          end

          def mapped_additional_training_initiative
            @mapped_additional_training_initiative ||= Hesa::CodeSets::TrainingInitiatives::MAPPING[additional_training_initiative]
          end

          def error_details
            {
              academic_cycle: academic_cycle&.label,
              additional_training_initiative: mapped_additional_training_initiative,
            }
          end
        end
      end
    end
  end
end
