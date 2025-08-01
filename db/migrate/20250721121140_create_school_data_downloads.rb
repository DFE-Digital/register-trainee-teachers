# frozen_string_literal: true

class CreateSchoolDataDownloads < ActiveRecord::Migration[7.0]
  def change
    create_table :school_data_downloads do |t|
      t.string :status, null: false
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :schools_created
      t.integer :schools_updated
      t.integer :lead_partners_updated

      t.timestamps
    end

    add_index :school_data_downloads, :status
    add_index :school_data_downloads, :started_at
  end
end
