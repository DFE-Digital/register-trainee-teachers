# frozen_string_literal: true

class AddSubmittedAtToBulkUpdateTraineeUploads < ActiveRecord::Migration[7.2]
  def change
    add_column :bulk_update_trainee_uploads, :submitted_at, :datetime
  end
end
