# frozen_string_literal: true

class AddErrorTypeToBulkUpdateRowError < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :bulk_update_row_errors, :error_type, :string, default: "validation", null: false

    add_index :bulk_update_row_errors, :error_type, algorithm: :concurrently
  end
end
