# frozen_string_literal: true

class DropBulkUpdateTraineeUploadsFileColumns < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_column :bulk_update_trainee_uploads, :file, :text, if_exists: true
      remove_column :bulk_update_trainee_uploads, :file_name, :string, if_exists: true
    end
  end
end
