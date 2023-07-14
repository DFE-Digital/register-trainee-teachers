# frozen_string_literal: true

class RemoveWithdrawReasonFromTrainee < ActiveRecord::Migration[7.0]
  def up
    remove_column :trainees, :withdraw_reason
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
