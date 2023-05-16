# frozen_string_literal: true

class TraineeWithdrawReasons < ActiveRecord::Migration[7.0]
  def up
    Trainee.withdrawn do |trainee|
      new_withdrawal_name = WithdrawalReasons::LEGACY_MAPPINGS[trainee.withdraw_reason]
      next unless new_withdrawal_name

      withdraw_reason = WithdrawReasons.find_by_name(new_withdrawal_name)
      trainee.withdraw_reasons << withdraw_reason
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
