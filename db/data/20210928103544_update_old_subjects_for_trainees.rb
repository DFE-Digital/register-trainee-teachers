# frozen_string_literal: true

class UpdateOldSubjectsForTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(course_subject_one: "creative arts and design").update_all(course_subject_one: CourseSubjects::ART_AND_DESIGN)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
