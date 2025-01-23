class ChangeBulkUpdateTraineeUploadsStatusDefault < ActiveRecord::Migration[7.2]
  def change
    change_column_default :bulk_update_trainee_uploads, :status, from: "pending", to: "uploaded"
  end
end
