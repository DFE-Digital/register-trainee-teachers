# frozen_string_literal: true

class BackfillEducationPhaseForTrainees < ActiveRecord::Migration[6.1]
  def up
    Trainee.where.not(course_subject_one: nil).each do |trainee|
      course_education_phase = trainee.course_subject_one.include?("primary") ? :primary : :secondary
      trainee.update(course_education_phase: course_education_phase)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
