# frozen_string_literal: true

class CreateBulkUpdatePlacements < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_update_placements do |t|
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
