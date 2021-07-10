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

  def save!
    return false unless valid?

    update_trainee_attributes
    trainee.save!
    clear_stash
  end

  def languages
    @languages ||= language_specialisms.reject(&:blank?)
  end

private

  def update_trainee_attributes
    trainee.assign_attributes({
      course_subject_one: languages.first,
      course_subject_two: languages.second,
      course_subject_three: languages.third,
    })
  end

  def compute_fields
    {
      language_specialisms: [
        trainee.course_subject_one,
        trainee.course_subject_two,
        trainee.course_subject_three,
      ].compact,
    }.merge(new_attributes)
  end

  def language_specialism_count
    if languages.empty?
      errors.add(:language_specialisms, :blank)
    elsif languages.length > 3
      errors.add(:language_specialisms, :invalid)
    end
  end
end
