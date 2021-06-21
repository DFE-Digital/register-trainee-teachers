# frozen_string_literal: true

class ConfirmPublishCourseForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    code
  ].freeze

  attr_accessor(*FIELDS, :trainee, :fields)

  delegate :id, :persisted?, to: :trainee

  validates :code, :course, presence: true

  def initialize(trainee, params = {})
    @trainee = trainee
    @params = params
    super(params)
  end

  def course
    @course ||= Course.find_by(code: code)
  end

  def save
    return false unless valid?

    update_trainee_attributes
    trainee.save!
  end

  def age_range
    course&.age_range
  end

  def course_start_date
    course&.start_date
  end

  def course_end_date
    course&.end_date
  end

  def course_code
    course&.code
  end

private

  def update_trainee_attributes
    trainee.progress.course_details = true
    trainee.assign_attributes({
      course_subject_one: course.subject_one&.name,
      course_subject_two: course.subject_two&.name,
      course_subject_three: course.subject_three&.name,
      course_code: course_code,
      course_age_range: course&.age_range,
      course_start_date: course_start_date,
      course_end_date: course_end_date,
    })
  end
end
