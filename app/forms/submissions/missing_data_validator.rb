# frozen_string_literal: true

module Submissions
  class MissingDataValidator < BaseValidator
    def missing_fields
      forms.map(&:missing_fields).flatten.uniq
    end

    def forms
      validator_keys.map { |key| validator(key) }
    end

  private

    def submission_ready
      errors.add(:trainee, :incomplete) unless missing_fields.empty?
    end
  end
end
