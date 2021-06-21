# frozen_string_literal: true

class ValidatePublishCourseForm < TraineeForm
  FIELDS = %i[
    course_subject_one
    course_age_range
    course_start_date
    course_end_date
  ].freeze

  attr_accessor(*FIELDS)

  validates :course_subject_one, presence: true

  delegate :apply_application?, to: :trainee

private

  def compute_fields
    {
      course_subject_one: trainee.course_subject_one,
      course_age_range: trainee.course_age_range,
      course_start_date: trainee.course_start_date,
      course_end_date: trainee.course_end_date,
    }
  end
end
