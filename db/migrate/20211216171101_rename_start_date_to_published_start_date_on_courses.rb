# frozen_string_literal: true

class RenameStartDateToPublishedStartDateOnCourses < ActiveRecord::Migration[6.1]
  def change
    rename_column :courses, :start_date, :published_start_date
  end
end
