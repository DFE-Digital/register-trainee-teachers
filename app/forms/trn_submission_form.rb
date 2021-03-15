# frozen_string_literal: true

class TrnSubmissionForm
  include ActiveModel::Model

  validate :submission_ready

  FORM_VALIDATORS =
    {
      personal_details: PersonalDetailsForm,
      contact_details: ContactDetailForm,
      diversity: Diversities::FormValidator,
      degrees: DegreeDetailForm,
      course_details: CourseDetailForm,
      training_details: TrainingDetailsForm,
    }.freeze

  PROGRESS_KEYS = FORM_VALIDATORS.keys.freeze

  def initialize(trainee:)
    @trainee = trainee
  end

  def section_status(progress_key)
    progress_service(progress_key).status.parameterize(separator: "_").to_sym
  end

  def all_sections_complete?
    PROGRESS_KEYS.all? do |progress_key|
      progress_is_completed?(progress_key)
    end
  end

private

  attr_reader :trainee

  def validator(section)
    FORM_VALIDATORS[section]
  end

  def submission_ready
    errors.add(:trainee, :incomplete) unless all_sections_complete?
  end

  def progress_service(progress_key)
    validator = validator(progress_key).new(trainee)
    progress_value = trainee.progress.public_send(progress_key)
    ProgressService.call(validator: validator, progress_value: progress_value)
  end

  def progress_is_completed?(progress_key)
    progress_service(progress_key).completed?
  end
end
