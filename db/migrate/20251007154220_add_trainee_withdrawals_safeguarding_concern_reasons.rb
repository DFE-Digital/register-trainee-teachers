# frozen_string_literal: true

class AddTraineeWithdrawalsSafeguardingConcernReasons < ActiveRecord::Migration[7.2]
  def change
    add_column :trainee_withdrawals, :safeguarding_concern_reasons, :string, null: true
  end
end
