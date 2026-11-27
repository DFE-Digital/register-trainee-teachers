# frozen_string_literal: true

module Api
  module V20261
    class HesaTraineeDetailAttributes
      class RulesValidator < ActiveModel::Validator
        def validate(record)
          rules = record.class::Rules

          record.errors.add(:fund_code, :ineligible) unless rules::FundCode.valid?(record)

          validation_result = rules::FundingMethod.call(record)
          record.errors.add(:funding_method, validation_result.error_type, **validation_result.error_details) unless validation_result.valid?

          validation_result = rules::TrainingInitiative.call(record)
          record.trainee_attributes.errors.add(:training_initiative, validation_result.error_type, **validation_result.error_details) unless validation_result.valid?

          additional_result = rules::AdditionalTrainingInitiative.call(record)
          record.errors.add(:additional_training_initiative, additional_result.error_type, **additional_result.error_details) unless additional_result.valid?

          validation_result = rules::CourseAgeRange.call(record)
          record.errors.add(:course_age_range, validation_result.error_type, **validation_result.error_details) unless validation_result.valid?
        end
      end
    end
  end
end
