# frozen_string_literal: true

class ConfirmPublishCourseForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    code
  ].freeze

  attr_accessor(*FIELDS, :trainee)

  delegate :id, :persisted?, to: :trainee

  validates :code, presence: true

  def initialize(trainee, params = {})
    @trainee = trainee
    super(params)
  end

  def save
    return false unless valid?

    update_trainee_attributes
    trainee.save!
  end

private

  def update_trainee_attributes
    trainee.progress.course_details = true
    trainee.assign_attributes({
      # Taking the first specialism for each subject until we have built
      # the capability for the user to choose from multiple options.
      course_subject_one: subject_specialisms[:course_subject_one].first,
      course_subject_two: subject_specialisms[:course_subject_two].first,
      course_subject_three: subject_specialisms[:course_subject_three].first,
      course_code: course.code,
      course_age_range: course.age_range,
      course_start_date: course.start_date,
      course_end_date: course.end_date,
    })
  end

  def course
    @course ||= Course.find_by(code: code)
  end

  def subject_specialisms
    @subject_specialisms ||= CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name))
  end
end
