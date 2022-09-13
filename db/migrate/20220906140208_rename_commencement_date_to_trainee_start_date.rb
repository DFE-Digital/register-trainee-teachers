# frozen_string_literal: true

class RenameCommencementDateToTraineeStartDate < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :commencement_date, :trainee_start_date
    rename_column :hesa_students, :commencement_date, :trainee_start_date
  end
end
