# frozen_string_literal: true

class CreateFundingTraineeSummaryRow < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_trainee_summary_rows do |t|
      t.integer :funding_trainee_summary_id, nullable: false
      t.string :subject, nullable: false
      t.string :route, nullable: false
      t.string :lead_school_name
      t.string :lead_school_urn
      t.string :cohort_level
      t.timestamps
    end

    add_index :funding_trainee_summary_rows,
              :funding_trainee_summary_id,
              name: "index_trainee_summary_rows_on_trainee_summary_id"
  end
end
