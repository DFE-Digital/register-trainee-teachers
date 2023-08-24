# frozen_string_literal: true

class CorrectCourseAllocationSubjectForNonDraft < ActiveRecord::Migration[7.0]
  def up
    trainees = Trainee.where.not(state: :draft).where(course_allocation_subject: nil)

    trainees.find_each do |trainee|
      SubjectSpecialism.find_by("lower(name) = ?", trainee.course_subject_one)&.allocation_subject.tap do |allocation_subject|
        trainee.update!(course_allocation_subject: allocation_subject)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
