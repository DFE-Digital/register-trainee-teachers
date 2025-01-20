class AddBulkUpdateTraineeUploadsNumberOfTrainees < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      add_column(
        :bulk_update_trainee_uploads,
        :number_of_trainees,
        :integer,
        null: false,
        default: 0,
      )
    end
  end
end
