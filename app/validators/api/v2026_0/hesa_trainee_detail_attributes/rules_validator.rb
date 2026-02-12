# frozen_string_literal: true

module Api
  module V20260
    class HesaTraineeDetailAttributes
      class RulesValidator < ActiveModel::Validator
        def validate(record)
          record.errors.add(:fund_code, :ineligible) unless Rules::FundCode.valid?(record)

          validation_result = Rules::FundingMethod.call(record)
          record.errors.add(:funding_method, validation_result.error_type, **validation_result.error_details) unless validation_result.valid?

          validation_result = Rules::TrainingInitiative.call(record)
          record.trainee_attributes.errors.add(:training_initiative, validation_result.error_type, **validation_result.error_details) unless validation_result.valid?

          additional_result = Rules::AdditionalTrainingInitiative.call(record)
          record.errors.add(:additional_training_initiative, additional_result.error_type, **additional_result.error_details) unless additional_result.valid?
        end
      end
    end
  end
end
