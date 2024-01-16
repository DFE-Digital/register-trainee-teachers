# frozen_string_literal: true

class CreateFundingUploads < ActiveRecord::Migration[7.1]
  def change
    create_table :funding_uploads do |t|
      t.integer :month
      t.integer :funding_type
      t.integer :status, default: 0
      t.text :csv_data

      t.timestamps
    end

    add_index :funding_uploads, :month
    add_index :funding_uploads, :funding_type
    add_index :funding_uploads, :status
  end
end
