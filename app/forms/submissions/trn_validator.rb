# frozen_string_literal: true

module Submissions
  class TrnValidator < BaseValidator
    def progress_status(progress_key)
      progress_service(progress_key).status.parameterize(separator: "_").to_sym
    end

    def display_type(section_key)
      progress = progress_status(section_key)
      progress == :completed ? :expanded : :collapsed
    end

    def all_sections_complete?
      validator_keys.all? do |key|
        progress_is_completed?(key)
      end
    end

  private

    def submission_ready
      errors.add(:trainee, :incomplete) unless all_sections_complete?
    end

    def progress_service(progress_key)
      progress_value = trainee.progress.public_send(progress_key)
      ProgressService.call(validator: validator(progress_key), progress_value: progress_value)
    end

    def progress_is_completed?(progress_key)
      progress_service(progress_key).completed?
    end
  end
end
