# frozen_string_literal: true

class AddSafeguardingWithdrawalReason < ActiveRecord::Migration[7.2]
  def change
    WithdrawalReason.upsert(
      { name: WithdrawalReasons::SAFEGUARDING_CONCERNS },
      unique_by: :name,
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
