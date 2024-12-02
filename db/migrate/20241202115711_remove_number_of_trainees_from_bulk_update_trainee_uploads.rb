# frozen_string_literal: true

class RemoveNumberOfTraineesFromBulkUpdateTraineeUploads < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :bulk_update_trainee_uploads, :number_of_trainees, :integer }
  end
end
