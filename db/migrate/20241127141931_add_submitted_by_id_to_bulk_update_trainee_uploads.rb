# frozen_string_literal: true

class AddSubmittedByIdToBulkUpdateTraineeUploads < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_reference :bulk_update_trainee_uploads,
        :submitted_by,
        index: {algorithm: :concurrently},
        foreign_key: { to_table: :users }
    end
  end
end
