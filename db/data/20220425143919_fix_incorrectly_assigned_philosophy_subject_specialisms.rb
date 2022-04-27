# frozen_string_literal: true

class FixIncorrectlyAssignedPhilosophySubjectSpecialisms < ActiveRecord::Migration[6.1]
  def up
    trainees = Trainee.where(course_subject_one: CourseSubjects::PHILOSOPHY).or(Trainee.where(course_subject_two: CourseSubjects::PHILOSOPHY)).or(Trainee.where(course_subject_three: CourseSubjects::PHILOSOPHY)).where(created_from_dttp: true)
    trainees.each do |trainee|
      if trainee.dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject1id_value"] == RELIGIOUS_EDUCATION_DTTP_ID
        trainee.update!(course_subject_one: CourseSubjects::RELIGIOUS_STUDIES)
      elsif trainee.dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject2id_value"] == RELIGIOUS_EDUCATION_DTTP_ID
        trainee.update!(course_subject_two: CourseSubjects::RELIGIOUS_STUDIES)
      elsif trainee.dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject3id_value"] == RELIGIOUS_EDUCATION_DTTP_ID
        trainee.update!(course_subject_three: CourseSubjects::RELIGIOUS_STUDIES)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
