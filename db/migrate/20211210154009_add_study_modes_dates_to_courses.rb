# frozen_string_literal: true

class AddStudyModesDatesToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :full_time_start_date, :date
    add_column :courses, :full_time_end_date, :date
    add_column :courses, :part_time_start_date, :date
    add_column :courses, :part_time_end_date, :date
  end
end
