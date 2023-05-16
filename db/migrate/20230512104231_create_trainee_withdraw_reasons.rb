# frozen_string_literal: true

class CreateTraineeWithdrawReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :trainee_withdraw_reasons do |t|
      t.references :trainee, null: false, foreign_key: true
      t.references :withdraw_reason, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trainee_withdraw_reasons, %i[trainee_id withdraw_reason_id], unique: true, name: :uniq_idx_trainee_withdaw_reasons
  end
end
