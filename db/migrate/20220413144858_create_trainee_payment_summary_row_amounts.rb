class CreateTraineePaymentSummaryRowAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :trainee_payment_summary_row_amounts do |t|
      t.integer :trainee_payment_summary_row_id, nullable: false
      t.integer :payment_type, nullable: false
      t.integer :tier
      t.integer :amount
      t.integer :number_of_trainees
      t.timestamps
    end

    add_index :trainee_payment_summary_row_amounts,
      :trainee_payment_summary_row_id,
      name: "index_trainee_payment_row_amounts_on_trainee_payment_row_id"
  end
end
