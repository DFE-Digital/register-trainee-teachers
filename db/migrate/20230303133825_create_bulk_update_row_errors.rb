class CreateBulkUpdateRowErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_update_row_errors do |t|
      t.timestamps

      t.bigint :errored_on_id
      t.string :errored_on_type
      t.string :message
    end
  end
end
