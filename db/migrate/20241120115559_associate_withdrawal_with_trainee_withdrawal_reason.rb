# frozen_string_literal: true

class AssociateWithdrawalWithTraineeWithdrawalReason < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Add the withdrawal_id column
    add_column :trainee_withdrawal_reasons, :withdrawal_id, :bigint

    # Add the foreign key without validation
    add_foreign_key :trainee_withdrawal_reasons, :trainee_withdrawals, column: :withdrawal_id, validate: false

    # Add the index concurrently
    add_index :trainee_withdrawal_reasons, [:withdrawal_id, :withdrawal_reason_id], 
              unique: true, 
              name: 'uniq_idx_withdrawal_id_withdrawal_reason_id',
              algorithm: :concurrently
  end

  def down
    # Remove the index
    remove_index :trainee_withdrawal_reasons, name: 'uniq_idx_withdrawal_id_withdrawal_reason_id'

    # Remove the foreign key
    remove_foreign_key :trainee_withdrawal_reasons, column: :withdrawal_id

    # Remove the withdrawal_id column
    remove_column :trainee_withdrawal_reasons, :withdrawal_id
  end
end
