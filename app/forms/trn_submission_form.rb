# frozen_string_literal: true

class TrnSubmissionForm
  include ActiveModel::Model

  validate :submission_ready

  VALIDATORS = [
    { validator: PersonalDetailForm, progress_key: :personal_details },
    { validator: ContactDetailForm, progress_key: :contact_details },
    { validator: DegreeDetailForm, progress_key: :degrees },
    { validator: Diversities::FormValidator, progress_key: :diversity },
    { validator: TrainingDetailsForm, progress_key: :training_details },
    { validator: ProgrammeDetailForm, progress_key: :programme_details },
  ].freeze

  def initialize(trainee:)
    @trainee = trainee
  end

  def all_sections_complete?
    VALIDATORS.all? do |validator_hash|
      validator = validator_hash[:validator].new(trainee)
      progress_value = trainee.progress.public_send(validator_hash[:progress_key])
      progress_is_completed?(validator, progress_value)
    end
  end

private

  attr_reader :trainee

  def submission_ready
    errors.add(:trainee, :incomplete) unless all_sections_complete?
  end

  def progress_is_completed?(validator, progress_value)
    ProgressService.call(validator: validator, progress_value: progress_value).completed?
  end
end
