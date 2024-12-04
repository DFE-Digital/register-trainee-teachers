# frozen_string_literal: true

class AddStatusIndexToBulkUpdateTraineeUpload < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :bulk_update_trainee_uploads, :status, algorithm: :concurrently
  end
end
