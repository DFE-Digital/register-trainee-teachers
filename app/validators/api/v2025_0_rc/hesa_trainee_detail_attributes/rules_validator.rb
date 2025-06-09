# frozen_string_literal: true

module Api
  module V20250Rc
    class HesaTraineeDetailAttributes
      class RulesValidator < ActiveModel::Validator
        def validate(record)
          record.errors.add(:fund_code, :ineligible) unless Rules::FundCode.valid?(record)

          validation_result = Rules::FundingMethod.valid?(record)
          record.errors.add(:funding_method, :ineligible, validation_result.second) unless validation_result.first
        end
      end
    end
  end
end
