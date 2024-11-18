# frozen_string_literal: true

class AddIndexErroredOnIdErroredOnTypeToBulkUpdateErrors < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :bulk_update_row_errors, %i[errored_on_id errored_on_type], algorithm: :concurrently
  end
end
