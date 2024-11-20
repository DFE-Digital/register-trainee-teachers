# frozen_string_literal: true

class MigrateWithdrawalDataToWithdrawals < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      WITH new_withdrawals AS (
        INSERT INTO withdrawals (trainee_id, date, created_at, updated_at)
        SELECT id, withdraw_date, NOW(), NOW()
        FROM trainees
        WHERE state = 4
        RETURNING trainee_id, id
      )
      UPDATE trainee_withdrawal_reasons twr
      SET withdrawal_id = nw.id
      FROM new_withdrawals nw
      WHERE twr.trainee_id = nw.trainee_id;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
