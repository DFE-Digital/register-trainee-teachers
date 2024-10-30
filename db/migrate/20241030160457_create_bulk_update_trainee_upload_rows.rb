class CreateBulkUpdateTraineeUploadRows < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_update_trainee_upload_rows do |t|
      t.references :bulk_update_trainee_upload, null: false, foreign_key: true
      t.integer :row_number, null: false
      t.jsonb :data, null: false
      t.jsonb :error_messages
      t.timestamps
    end

    safety_assured { remove_column :bulk_update_trainee_uploads, :error_messages, :jsonb }

    add_index :bulk_update_trainee_upload_rows, [:bulk_update_trainee_upload_id, :row_number], unique: true, name: "index_bulk_update_trainee_upload_rows_on_upload_and_row_number"
  end
end
