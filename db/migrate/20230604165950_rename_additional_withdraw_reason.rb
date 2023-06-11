class RenameAdditionalWithdrawReason < ActiveRecord::Migration[7.0]
  def change
    rename_column :trainees, :additional_withdraw_reason, :withdraw_reasons_details
    add_column :trainees, :withdraw_reasons_dfe_details, :string
  end
end
