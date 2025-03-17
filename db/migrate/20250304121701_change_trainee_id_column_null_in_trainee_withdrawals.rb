# frozen_string_literal: true

class ChangeTraineeIdColumnNullInTraineeWithdrawals < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_column_null :trainee_withdrawals, :trainee_id, false
    end
  end
end
