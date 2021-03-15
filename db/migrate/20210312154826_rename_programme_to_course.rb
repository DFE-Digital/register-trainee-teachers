# frozen_string_literal: true

class RenameProgrammeToCourse < ActiveRecord::Migration[6.1]
  def change
    rename_column :trainees, :programme_start_date, :course_start_date
    rename_column :trainees, :programme_end_date, :course_end_date
  end
end
