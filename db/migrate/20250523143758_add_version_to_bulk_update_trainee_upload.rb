class AddVersionToBulkUpdateTraineeUpload < ActiveRecord::Migration[7.2]
  def change
    add_column :bulk_update_trainee_uploads, :version, :string

    reversible do |dir|
      dir.up do
        BulkUpdate::TraineeUpload.update_all(version: "2025.0")

        safety_assured do
          change_column_null :bulk_update_trainee_uploads, :version, false
        end
      end
    end
  end
end
