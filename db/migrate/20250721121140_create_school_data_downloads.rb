# frozen_string_literal: true

class CreateSchoolDataDownloads < ActiveRecord::Migration[7.2]
  def change
    create_table :school_data_downloads do |t|
      t.string :status
      t.datetime :started_at
      t.datetime :completed_at
      t.string :source
      t.text :error_message
      t.integer :rows_processed
      t.integer :rows_filtered
      t.integer :schools_created
      t.integer :schools_updated
      t.integer :lead_partners_updated

      t.timestamps
    end
  end
end
