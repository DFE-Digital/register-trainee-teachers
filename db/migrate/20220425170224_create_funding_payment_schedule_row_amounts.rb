# frozen_string_literal: true

class CreateFundingPaymentScheduleRowAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_payment_schedule_row_amounts do |t|
      t.integer :funding_payment_schedule_row_id, nullable: false
      t.integer :month, nullable: false
      t.integer :year, nullable: false
      t.integer :amount_in_pence
      t.boolean :predicted
      t.timestamps
    end

    add_index :funding_payment_schedule_row_amounts,
              :funding_payment_schedule_row_id,
              name: "index_payment_schedule_row_amounts_on_payment_schedule_row_id"
  end
end
