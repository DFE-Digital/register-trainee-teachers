class RemoveWithdrawReasonFromTrainee < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :trainees, :withdraw_reason, :integer }
  end
end
