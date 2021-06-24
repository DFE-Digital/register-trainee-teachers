# frozen_string_literal: true

class ChangePrimaryToPrimaryTeaching < ActiveRecord::Migration[6.1]
  def up
    Trainee.where(course_subject_one: "Primary").update_all(course_subject_one: Dttp::CodeSets::CourseSubjects::PRIMARY_TEACHING)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
