# frozen_string_literal: true

module Submissions
  class MissingDataValidator < BaseValidator
    class_attribute :extra_validators, instance_writer: false, default: {}

    OPTIONAL_FIELDS = %i[placements training_partner_id employing_school_id].freeze

    class << self
      def missing_data_validator(name, options)
        extra_validators[name] = options
      end
    end

    missing_data_validator :trainee_start_date, form: "TraineeStartDateForm", if: :course_already_started?
    missing_data_validator :placements, form: "PlacementsForm", if: :requires_placements?

    def missing_fields
      forms.map(&:missing_fields).tap do |fields|
        fields << degrees_form.errors.attribute_names if degrees_form.present?
      end.flatten.uniq
    end

    def course_already_started?
      !trainee.starts_course_in_the_future?
    end

    def forms
      @forms ||= validator_keys.map { |key| validator(key) }
    end

  private

    def degrees_form
      @degrees_form ||= forms.detect { |form| form.is_a?(DegreesForm) }
    end

    def submission_ready
      errors.add(:trainee, :incomplete) unless missing_fields.excluding(OPTIONAL_FIELDS).empty?
    end
  end
end
