# frozen_string_literal: true

class CreateTraineeWithdrawals < ActiveRecord::Migration[7.2]
  def up
    create_enum :trigger_type, %i[provider trainee]
    create_enum :future_interest_type, %i[yes no unknown]

    create_table :trainee_withdrawals do |t|
      t.belongs_to :trainee, null: true, foreign_key: true
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

    drop_enum :trigger_type
    drop_enum :future_interest_type
  end
end
