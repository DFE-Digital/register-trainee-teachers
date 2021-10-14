# frozen_string_literal: true

class UpdateWithdrawnDttpStatus < ActiveRecord::Migration[6.1]
  def up
    Trainee.withdrawn.each do |trainee|
      # Withdraw the trainee again to update their status, everything else should remain the same.
      Dttp::WithdrawJob.perform_later(trainee)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
