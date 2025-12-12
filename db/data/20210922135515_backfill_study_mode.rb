# frozen_string_literal: true

class BackfillStudyMode < ActiveRecord::Migration[6.1]
  def up
    Trainee.includes(:published_course).where(study_mode: nil).where.not(course_code: nil).find_each do |trainee|
      if (course = trainee.published_course)
        study_mode = course_study_mode_if_valid(course)
        trainee.update!(study_mode:) if study_mode
      end
    end
  end

  def course_study_mode_if_valid(course)
    course.study_mode if ReferenceData::TRAINEE_STUDY_MODES.names.include?(course.study_mode)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
