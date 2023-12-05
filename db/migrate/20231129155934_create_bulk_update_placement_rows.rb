# frozen_string_literal: true

class CreateBulkUpdatePlacementRows < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_update_placement_rows do |t|
      t.timestamps

      t.integer :state, null: false, default: 0
      t.references :bulk_update_placement, null: false, foreign_key: true
      t.integer :csv_row_number, null: false
      t.string :urn, null: false
      t.string :trn, null: false
      t.references :school, null: true, foreign_key: true
    end

    add_index :bulk_update_placement_rows,
              %i[bulk_update_placement_id csv_row_number trn urn],
              unique: true,
              name: :idx_uniq_placement_rows
  end
end
