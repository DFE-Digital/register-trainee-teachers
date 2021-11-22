# frozen_string_literal: true

module Submissions
  class MissingDataValidator < BaseValidator
    class_attribute :extra_validators, instance_writer: false, default: {}

    class << self
      def missing_data_validator(name, options)
        extra_validators[name] = options
      end
    end

    missing_data_validator :trainee_start_date, form: "TraineeStartDateForm", if: :course_already_started?

    def missing_fields
      forms.map(&:missing_fields).flatten.uniq
    end

    def course_already_started?
      !trainee.starts_course_in_the_future?
    end

  private

    def forms
      validator_keys.map { |key| validator(key) }
    end

    def submission_ready
      errors.add(:trainee, :incomplete) unless missing_fields.empty?
    end
  end
end
