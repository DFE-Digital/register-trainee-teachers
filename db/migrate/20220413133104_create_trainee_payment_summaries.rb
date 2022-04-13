class CreateTraineePaymentSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :trainee_payment_summaries do |t|
      t.integer :payable_id, nullable: false
      t.string :payable_type, nullable: false
      t.string :academic_year, nullable: false
      t.timestamps
    end

    add_index :trainee_payment_summaries, [:payable_id, :payable_type]
  end
end
