# frozen_string_literal: true

class AssociateWithdrawalWithTraineeWithdrawalReason < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Add the withdrawal_id column
    add_column :trainee_withdrawal_reasons, :trainee_withdrawal_id, :bigint

    # Add the foreign key without validation
    add_foreign_key :trainee_withdrawal_reasons, :trainee_withdrawals, column: :trainee_withdrawal_id, validate: false

    # Add the index concurrently
    add_index :trainee_withdrawal_reasons, %i[trainee_withdrawal_id withdrawal_reason_id],
              unique: true,
              name: "uniq_idx_trainee_withdrawal_id_withdrawal_reason_id",
              algorithm: :concurrently
  end

  def down
    # Remove the index
    remove_index :trainee_withdrawal_reasons, name: "uniq_idx_trainee_withdrawal_id_withdrawal_reason_id"

    # Remove the foreign key
    remove_foreign_key :trainee_withdrawal_reasons, column: :trainee_withdrawal_id

    # Remove the trainee_withdrawal_id column
    remove_column :trainee_withdrawal_reasons, :trainee_withdrawal_id
  end
end
