# frozen_string_literal: true

class UpdateTraineeWithdrawalDate < ActiveRecord::Migration[6.1]
  def up
    Trainee.find_by(trn: 2075439)&.update(withdraw_date: Date.parse("01/09/2021"))
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
