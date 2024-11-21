# frozen_string_literal: true

class AddStatusDefaultToBulkUpdateTraineeUploads < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_column_default :bulk_update_trainee_uploads, :status, from: nil, to: :pending
    end
  end
end
