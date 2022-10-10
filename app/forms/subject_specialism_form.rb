# frozen_string_literal: true

class SubjectSpecialismForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include CourseFormHelpers

  FIELDS = %i[
    course_subject_one
    course_subject_two
    course_subject_three
  ].freeze

  ERROR_TRANSLATION_KEY =
    "activemodel.errors.models.subject_specialism_form.attributes.specialism.blank"

  validate :specialism_is_present

  attr_accessor(*FIELDS)

  def initialize(trainee, position = nil, params: {}, user: nil, store: FormStore)
    @position = position
    super(trainee, params: course_subjects(params), user: user, store: store)
  end

  def specialisms
    @specialisms ||= [
      course_subject_one,
      course_subject_two,
      course_subject_three,
    ].compact
  end

  def save!
    return false unless valid?

    trainee.assign_attributes(
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
      course_allocation_subject: course_allocation_subject,
    )
    clear_funding_information if clear_funding_information?
    Trainees::Update.call(trainee: trainee)
    clear_stash
  end

  def stash
    form = CourseDetailsForm.new(trainee)
    form.assign_attributes_and_stash({
      course_subject_one: course_subject_one,
      course_subject_two: course_subject_two,
      course_subject_three: course_subject_three,
    })

    super
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
  end

  def subject_attribute(position = @position)
    "course_subject_#{to_word(position)}"
  end

  def to_word(number)
    case number
    when 1
      "one"
    when 2
      "two"
    when 3
      "three"
    end
  end

  def specialism_is_present
    if @position && public_send(subject_attribute).blank?
      errors.add(subject_attribute, I18n.t(ERROR_TRANSLATION_KEY))
    end
  end

  def course_subjects(params)
    subjects = params.slice(:course_subject_one, :course_subject_two, :course_subject_three)

    return {} if subjects.blank?

    case @position
    when 1
      subjects[:course_subject_two] = nil
      subjects[:course_subject_three] = nil
    when 2
      subjects.delete(:course_subject_one)
      subjects[:course_subject_three] = nil
    when 3
      subjects.delete(:course_subject_one)
      subjects.delete(:course_subject_two)
    end

    subjects
  end
end
