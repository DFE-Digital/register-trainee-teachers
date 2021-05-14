# frozen_string_literal: true

class AddCourseCodeToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :course_code, :string
  end
end
