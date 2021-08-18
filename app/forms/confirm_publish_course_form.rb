# frozen_string_literal: true

class ConfirmPublishCourseForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include CourseFormHelpers

  FIELDS = %i[
    code
  ].freeze

  attr_accessor(*FIELDS, :trainee, :specialisms, :itt_start_date, :course_study_mode)

  delegate :id, :persisted?, to: :trainee

  validates :code, presence: true

  def initialize(trainee, specialisms, itt_start_date, course_study_mode, params = {})
    @trainee = trainee
    @specialisms = specialisms
    @itt_start_date = itt_start_date
    @course_study_mode = course_study_mode
    super(params)
  end

  def save
    return false unless valid?

    update_trainee_attributes

    clear_bursary_information if course_subjects_changed?
    trainee.save!
  end

private

  def study_mode
    return unless trainee.requires_study_mode?

    course_study_mode || course.study_mode
  end

  def update_trainee_attributes
    specialism1, specialism2, specialism3 = *specialisms
    trainee.progress.course_details = true

    trainee.assign_attributes({
      course_subject_one: specialism1,
      course_subject_two: specialism2,
      course_subject_three: specialism3,
      course_code: course.code,
      course_age_range: course.age_range,
      course_start_date: itt_start_date || course.start_date,
      study_mode: study_mode,
      course_end_date: course.end_date,
    })
  end

  def course
    @course ||= trainee.available_courses.find_by(code: code)
  end
end
