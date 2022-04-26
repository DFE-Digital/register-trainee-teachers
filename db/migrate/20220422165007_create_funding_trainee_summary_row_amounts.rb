# frozen_string_literal: true

class CreateFundingTraineeSummaryRowAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_trainee_summary_row_amounts do |t|
      t.integer :funding_trainee_summary_row_id, nullable: false
      t.integer :payment_type, nullable: false
      t.integer :tier
      t.integer :amount
      t.integer :number_of_trainees
      t.timestamps
    end

    add_index :funding_trainee_summary_row_amounts,
              :funding_trainee_summary_row_id,
              name: "index_trainee_summary_row_amounts_on_trainee_summary_row_id"
  end
end
