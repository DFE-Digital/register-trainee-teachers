# frozen_string_literal: true

class LanguageSpecialismsForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    language_specialisms
    course_subject_one
    course_subject_two
    course_subject_three
  ].freeze

  attr_accessor(*FIELDS, :trainee)

  delegate :id, :persisted?, to: :trainee

  validate :language_specialism_count

  def initialize(trainee, params: {}, user: nil, store: FormStore)
    params.merge!(course_subjects(params[:language_specialisms]))
    super(trainee, params: params, user: user, store: store)
  end

  def languages
    @languages ||= [
      course_subject_one,
      course_subject_two,
      course_subject_three,
    ].reject(&:blank?)
  end

  def language_specialisms
    (@language_specialisms || []).reject(&:blank?)
  end

private

  def compute_fields
    course_subjects(languages_specialisms_from_trainee_record).merge(new_attributes)
  end

  def course_subjects(subjects)
    subjects = (subjects || []).reject(&:blank?)
    {
      course_subject_one: subjects[0],
      course_subject_two: subjects[1],
      course_subject_three: subjects[2],
    }
  end

  def language_specialism_count
    if language_specialisms.empty?
      errors.add(:language_specialisms, :blank)
    elsif language_specialisms.length > 3
      errors.add(:language_specialisms, :invalid)
    end
  end

  def fields_to_ignore_before_stash_or_save
    %i[
      language_specialisms
    ]
  end

  def languages_specialisms_from_trainee_record
    # If the course subjects are not language specialisms, they shouldn't be included
    trainee.course_subjects & PUBLISH_SUBJECT_SPECIALISM_MAPPING[PublishSubjects::MODERN_LANGUAGES]
  end
end
