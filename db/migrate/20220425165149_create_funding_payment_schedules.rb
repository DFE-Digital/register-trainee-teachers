# frozen_string_literal: true

class CreateFundingPaymentSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_payment_schedules do |t|
      t.integer :payable_id, nullable: false
      t.string :payable_type, nullable: false
      t.timestamps
    end

    add_index :funding_payment_schedules, %i[payable_id payable_type]
  end
end
