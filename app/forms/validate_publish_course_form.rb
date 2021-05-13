# frozen_string_literal: true

class ValidatePublishCourseForm < TraineeForm
  FIELDS = %i[
    subject
    age_range
    course_start_date
    course_end_date
  ].freeze

  attr_accessor(*FIELDS)

  validates :subject, presence: true

  delegate :apply_application?, to: :trainee

private

  def compute_fields
    {
      subject: trainee.subject,
      age_range: trainee.age_range,
      course_start_date: trainee.course_start_date,
      course_end_date: trainee.course_end_date,
    }
  end
end
