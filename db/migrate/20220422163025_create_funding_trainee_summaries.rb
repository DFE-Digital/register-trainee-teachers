# frozen_string_literal: true

class CreateFundingTraineeSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :funding_trainee_summaries do |t|
      t.integer :payable_id, nullable: false
      t.string :payable_type, nullable: false
      t.string :academic_year, nullable: false
      t.timestamps
    end

    add_index :funding_trainee_summaries, %i[payable_id payable_type]
  end
end
