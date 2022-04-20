# frozen_string_literal: true

class AddCourseAllocationSubjectToTrainees < ActiveRecord::Migration[6.1]
  def change
    add_reference :trainees, :course_allocation_subject, foreign_key: { to_table: "allocation_subjects" }
  end
end
