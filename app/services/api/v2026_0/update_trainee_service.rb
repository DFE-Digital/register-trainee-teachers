# frozen_string_literal: true

module Api
  module V20260
    class UpdateTraineeService < Api::V20250::UpdateTraineeService
      def call
        trainee_attributes_validation = TraineeAttributesValidation.new(trainee_attributes:)
        attributes_to_save = attributes.deep_attributes.with_indifferent_access
        trainee.nationalities.destroy_all if attributes_to_save[:nationalisations_attributes].present?
        trainee.clear_disabilities if attributes_to_save[:trainee_disabilities_attributes].present?

        if trainee_attributes_validation.invalid?
          [false, trainee_attributes_validation]
        else
          trainee.assign_attributes(attributes_to_save)
          trainee.disabilities = [] if !trainee.disabled? && trainee.disability_disclosure_changed?

          [trainee.save, trainee]
        end
      end
    end
  end
end
