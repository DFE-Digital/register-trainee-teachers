# frozen_string_literal: true

class LanguageSpecialismsForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    language_specialisms
  ].freeze

  attr_accessor(*FIELDS, :trainee)

  delegate :id, :persisted?, to: :trainee

  validate :language_specialism_count

  def languages
    @languages ||= language_specialisms.reject(&:blank?)
  end

private

  def compute_fields
    { language_specialisms: languages_specialisms_from_trainee_record }.merge(new_attributes)
  end

  def language_specialism_count
    if languages.empty?
      errors.add(:language_specialisms, :blank)
    elsif languages.length > 3
      errors.add(:language_specialisms, :invalid)
    end
  end

  def languages_specialisms_from_trainee_record
    # If the course subjects are not language specialisms, they shouldn't be included
    trainee.course_subjects & PUBLISH_SUBJECT_SPECIALISM_MAPPING[PublishSubjects::MODERN_LANGUAGES]
  end
end
