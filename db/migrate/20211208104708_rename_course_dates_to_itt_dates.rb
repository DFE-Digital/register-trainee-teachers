# frozen_string_literal: true

class RenameCourseDatesToIttDates < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :course_start_date, :itt_start_date
    rename_column :trainees, :course_end_date, :itt_end_date
  end
end
