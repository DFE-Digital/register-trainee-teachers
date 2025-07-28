# frozen_string_literal: true

class LanguageSpecialismsForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  include CourseFormHelpers

  FIELDS = %i[
    language_specialisms
    course_subject_one
    course_subject_two
    course_subject_three
  ].freeze

  attr_accessor(*FIELDS)

  validate :language_specialism_count, :language_specialism_duplicates

  def initialize(trainee, params: {}, user: nil, store: FormStore)
    params.merge!(course_subjects(params[:language_specialisms]))

    super
  end

  def languages
    @languages ||= [
      course_subject_one,
      course_subject_two,
      course_subject_three,
    ].compact_blank
  end

  def language_specialisms
    (@language_specialisms || []).compact_blank
  end

  def save!
    return false unless valid?

    trainee.assign_attributes(
      course_subject_one:,
      course_subject_two:,
      course_subject_three:,
      course_allocation_subject:,
    )
    Trainees::Update.call(trainee:)
    clear_stash
  end

  def stash
    form = CourseDetailsForm.new(trainee)
    form.assign_attributes_and_stash({
      course_subject_one:,
      course_subject_two:,
      course_subject_three:,
    })

    super
  end

  def non_language_subject
    return nil unless @trainee.published_course&.subjects&.any?

    @non_language_subject ||= (@trainee.published_course.subjects.map(&:name) - PUBLISH_MODERN_LANGUAGES).first
  end

private

  def compute_fields
    course_subjects(languages_specialisms_from_trainee_record).merge(new_attributes)
  end

  def course_subjects(subjects)
    subjects = (subjects || []).compact_blank
    return {} if subjects.blank?

    {
      course_subject_one: subjects[0],
      course_subject_two: subjects[1],
      course_subject_three: subjects[2],
    }
  end

  def language_specialism_count
    if course_subject_one.blank?
      errors.add(:course_subject_one, :blank)
    end
  end

  def language_specialism_duplicates
    if languages.count > languages.uniq.count
      errors.add(:course_subject_one, :invalid)
    end
  end

  def fields_to_ignore_before_save
    %i[language_specialisms]
  end

  def fields_to_ignore_before_stash
    %i[language_specialisms]
  end

  def languages_specialisms_from_trainee_record
    # If the course subjects are not language specialisms, they shouldn't be included
    trainee.course_subjects & PUBLISH_SUBJECT_SPECIALISM_MAPPING[PublishSubjects::MODERN_LANGUAGES]
  end
end
