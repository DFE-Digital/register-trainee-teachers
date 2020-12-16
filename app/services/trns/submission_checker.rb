# frozen_string_literal: true

module Trns
  class SubmissionChecker
    include ServicePattern

    attr_reader :trainee, :successful
    alias_method :successful?, :successful

    VALIDATORS = [
      { validator: PersonalDetailForm, progress_key: :personal_details },
      { validator: ContactDetailForm, progress_key: :contact_details },
      { validator: DegreeDetailForm, progress_key: :degrees },
      { validator: Diversities::FormValidator, progress_key: :diversity },
      { validator: ProgrammeDetailForm, progress_key: :programme_details },
    ].freeze

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      @successful = is_submission_ready?

      self
    end

  private

    def is_submission_ready?
      VALIDATORS.all? do |validator_hash|
        validator = validator_hash[:validator].new(trainee)
        progress_value = trainee.progress.public_send(validator_hash[:progress_key])

        progress_is_completed?(validator, progress_value)
      end
    end

    def progress_is_completed?(validator, progress_value)
      ProgressService.call(validator: validator, progress_value: progress_value).completed?
    end
  end
end
