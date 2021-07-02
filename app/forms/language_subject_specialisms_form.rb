# frozen_string_literal: true

class LanguageSubjectSpecialismsForm < TraineeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    subject_specialisms
  ].freeze

  attr_accessor(*FIELDS, :trainee)

  delegate :id, :persisted?, to: :trainee

  validate :subject_specialism_count

  def save!
    return false unless valid?

    update_trainee_attributes
    trainee.save!
    clear_stash
  end

private

  def update_trainee_attributes
    trainee.assign_attributes({
      course_subject_one: subjects.first,
      course_subject_two: subjects.second,
      course_subject_three: subjects.third,
    })
  end

  def compute_fields
    {
      subject_specialisms: [
        trainee.course_subject_one,
        trainee.course_subject_two,
        trainee.course_subject_three,
      ].compact,
    }.merge(new_attributes)
  end

  def subjects
    @subjects ||= subject_specialisms.reject(&:blank?)
  end

  def subject_specialism_count
    if subjects.empty?
      errors.add(:subject_specialisms, :blank)
    elsif subjects.length > 3
      errors.add(:subject_specialisms, :invalid)
    end
  end
end
