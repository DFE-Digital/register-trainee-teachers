# frozen_string_literal: true

class CreateSchoolDataDownloads < ActiveRecord::Migration[7.2]
  def change
    create_table :school_data_downloads do |t|
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.integer :status, default: 0, null: false
      t.text :error_message
      t.integer :file_count
      t.integer :schools_created, default: 0
      t.integer :schools_updated, default: 0

      t.timestamps
    end

    add_index :school_data_downloads, :started_at
    add_index :school_data_downloads, :status
  end
end
