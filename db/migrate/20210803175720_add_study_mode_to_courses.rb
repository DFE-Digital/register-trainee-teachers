# frozen_string_literal: true

class AddStudyModeToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :study_mode, :integer
  end
end
