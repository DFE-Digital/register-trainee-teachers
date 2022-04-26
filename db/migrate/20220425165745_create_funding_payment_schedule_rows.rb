# frozen_string_literal: true

class CreateFundingPaymentScheduleRows < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_payment_schedule_rows do |t|
      t.integer :funding_payment_schedule_id, nullable: false
      t.string :description
      t.timestamps
    end

    add_index :funding_payment_schedule_rows,
              :funding_payment_schedule_id,
              name: "index_payment_schedule_rows_on_funding_payment_schedule_id"
  end
end
