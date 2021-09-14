# frozen_string_literal: true

class AddCourseEducationPhaseToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_column :trainees, :course_education_phase, :integer
  end
end
