# frozen_string_literal: true

class ValidateAssociateWithdrawalWithTraineeWithdrawalReason < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :trainee_withdrawal_reasons, :trainee_withdrawals
  end
end
