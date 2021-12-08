# frozen_string_literal: true

class ValidatePublishCourseForm < TraineeForm
  FIELDS = %i[
    course_subject_one
    course_age_range
    itt_start_date
    itt_end_date
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_subject_one, presence: true

  delegate :apply_application?, to: :trainee

private

  def compute_fields
    {
      course_subject_one: trainee.course_subject_one,
      course_age_range: trainee.course_age_range,
      itt_start_date: trainee.itt_start_date,
      itt_end_date: trainee.itt_end_date,
    }
  end
end
