# frozen_string_literal: true

module Trns
  class SubmissionChecker
    attr_reader :trainee, :successful
    alias_method :successful?, :successful

    VALIDATORS = [
      { validator: PersonalDetail, progress_key: :personal_details },
      { validator: ContactDetail, progress_key: :contact_details },
      { validator: DegreeDetail, progress_key: :degrees },
      { validator: Diversities::DiversityFlow, progress_key: :diversity },
      { validator: ProgrammeDetail, progress_key: :programme_details },
    ].freeze

    class PreSubmissionError < StandardError
    end

    class << self
      def call(trainee)
        new(trainee).call
      end
    end

    def initialize(trainee)
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
