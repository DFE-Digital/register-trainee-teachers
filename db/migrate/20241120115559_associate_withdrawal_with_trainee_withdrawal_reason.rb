# frozen_string_literal: true

class AssociateWithdrawalWithTraineeWithdrawalReason < ActiveRecord::Migration[7.2]
  # trainee_id will be removed in a later migration
  def change
    add_reference :trainee_withdrawal_reasons, :withdrawal, foreign_key: { to_table: :trainee_withdrawals }
    # NULL values in withdrawal_id are treated as distinct in postgres, so won't violate the uniqueness constraint
    add_index :trainee_withdrawal_reasons, [:withdrawal_id, :withdrawal_reason_id], unique: true, name: 'uniq_idx_withdrawal_id_withdrawal_reason_id'
  end
end
