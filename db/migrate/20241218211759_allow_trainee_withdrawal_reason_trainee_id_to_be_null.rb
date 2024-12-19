# frozen_string_literal: true

class AllowTraineeWithdrawalReasonTraineeIdToBeNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :trainee_withdrawal_reasons, :trainee_id, true
  end
end
