# frozen_string_literal: true

class CreateTraineeWithdrawalReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :trainee_withdrawal_reasons do |t|
      t.references :trainee, null: false, foreign_key: true
      t.references :withdrawal_reason, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trainee_withdrawal_reasons, %i[trainee_id withdrawal_reason_id], unique: true, name: :uniq_idx_trainee_withdawal_reasons
  end
end
