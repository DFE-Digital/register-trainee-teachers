class CreateTraineePaymentSummaryRows < ActiveRecord::Migration[6.1]
  def change
    create_table :trainee_payment_summary_rows do |t|
      t.integer :trainee_payment_summary_id, nullable: false
      t.string :subject, nullable: false
      t.string :route, nullable: false
      t.string :lead_school_name
      t.string :lead_school_urn
      t.string :cohort_level

      t.timestamps
    end

    add_index :trainee_payment_summary_rows,
      :trainee_payment_summary_id,
      name: 'index_trainee_payment_rows_on_trainee_payment_summary_id'
  end
end
