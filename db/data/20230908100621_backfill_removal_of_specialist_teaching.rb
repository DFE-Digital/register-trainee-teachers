# frozen_string_literal: true

class BackfillRemovalOfSpecialistTeaching < ActiveRecord::Migration[7.0]
  def up
    # Recalculate subjects and allocation subject for trainees on the old specialist teaching subject or allocation subject as they're both being removed. This should now be:
    # course_subject_one = "primary teaching"
    # course_subject_two = "mathematics"
    # course_allocation_subject = "Primary" since the first subject is now "primary teaching"
    Trainee.includes(:course_allocation_subject).where(course_subject_one: "specialist teaching (primary with mathematics)").or(
      Trainee.includes(:course_allocation_subject).where(course_subject_one: "primary teaching", course_allocation_subject: { name: "Primary with mathematics" }),
    ).find_each do |trainee|
      if trainee.course_uuid.present?
        subject_one, subject_two, subject_three = calculate_subject_specialisms(
          Course.find_by(uuid: trainee.course_uuid).subjects.pluck(:name),
        )
      else
        subject_one, subject_two, subject_three = calculate_subject_specialisms([PublishSubjects::PRIMARY_WITH_MATHEMATICS])
      end

      allocation_subject = SubjectSpecialism.find_by("lower(name) = ?", subject_one.downcase)&.allocation_subject

      trainee.update!(
        course_subject_one: subject_one,
        course_subject_two: subject_two,
        course_subject_three: subject_three,
        course_allocation_subject: allocation_subject,
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private

  def calculate_subject_specialisms(subjects)
    CalculateSubjectSpecialisms.call(subjects:).values.map(&:first).compact
  end
end
