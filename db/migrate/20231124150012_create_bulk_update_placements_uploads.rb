class CreateBulkUpdatePlacementsUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_update_placements_uploads do |t|
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
