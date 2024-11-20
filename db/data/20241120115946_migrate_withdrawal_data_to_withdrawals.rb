# frozen_string_literal: true

class MigrateWithdrawalDataToWithdrawals < ActiveRecord::Migration[7.2]
  def up
    Trainee.withdrawn.find_each do |trainee|
      withdrawal = Trainee::Withdrawal.create!(
        trainee_id: trainee.id,
        date: trainee.withdraw_date,
      )

      TraineeWithdrawalReason.where(trainee_id: trainee.id).update_all(withdrawal_id: withdrawal.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
