# frozen_string_literal: true

class MoveTraineesToNewGeneralSciencesAllocationSubject < ActiveRecord::Migration[6.1]
  def up
    biology_allocation_subject = AllocationSubject.find_by(name: AllocationSubjects::BIOLOGY)
    general_sciences_allocation_subject = AllocationSubject.find_by(name: AllocationSubjects::GENERAL_SCIENCES)

    Trainee.where(course_allocation_subject: biology_allocation_subject,
                  course_subject_one: AllocationSubjects::GENERAL_SCIENCES.downcase).find_each do |trainee|
      trainee.update_columns(course_allocation_subject_id: general_sciences_allocation_subject.id,
                             applying_for_bursary: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
