# frozen_string_literal: true

class CreateTraineeWithdrawals < ActiveRecord::Migration[7.2]
  def up
    safety_assured {
      execute <<-SQL
        CREATE TYPE trigger_type AS ENUM ('provider', 'trainee');
        CREATE TYPE future_interest_type AS ENUM ('yes', 'no', 'unknown');
      SQL
    }

    create_table :trainee_withdrawals do |t|
      t.belongs_to :trainee, null: false, foreign_key: true
      t.date :date
      t.column :trigger, :trigger_type
      t.string :another_reason
      t.column :future_interest, :future_interest_type
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :trainee_withdrawals, :discarded_at
  end

  def down
    drop_table :trainee_withdrawals

    safety_assured {
      execute <<-SQL
        DROP TYPE trigger_type;
        DROP TYPE future_interest_type;
      SQL
    }
  end
end
