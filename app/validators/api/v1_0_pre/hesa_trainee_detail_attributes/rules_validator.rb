# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes
      class RulesValidator < ActiveModel::Validator
        def validate(record)
          record.errors.add(:fund_code, :ineligible) unless Rules::FundCode.valid?(record)
          record.errors.add(:funding_method, :ineligible) unless Rules::FundingMethod.valid?(record)
        end
      end
    end
  end
end
