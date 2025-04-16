# frozen_string_literal: true

module Api
  module V10Pre
    class HesaTraineeDetailAttributes
      class RulesValidator < ActiveModel::Validator
        def validate(record)
          return if record.errors.present?

          record.errors.add(:fund_code, :ineligible) unless Rules::FundCode.valid?(record)
        end
      end
    end
  end
end
