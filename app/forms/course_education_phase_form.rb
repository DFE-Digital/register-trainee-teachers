# frozen_string_literal: true

class CourseEducationPhaseForm < TraineeForm
  FIELDS = %i[
    course_education_phase
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_education_phase, presence: true

  def save!
    if valid?
      trainee.assign_attributes(fields.except(*fields_to_ignore_before_stash_or_save))
      clear_course_subjects if trainee.course_education_phase_changed?
      trainee.save!
      clear_stash
    else
      false
    end
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def clear_course_subjects
    trainee.assign_attributes(course_subject_one: nil, course_subject_two: nil, course_subject_three: nil, course_age_range: nil)
  end
end
