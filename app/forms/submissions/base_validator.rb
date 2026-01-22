# frozen_string_literal: true

module Submissions
  class BaseValidator
    include ActiveModel::Model

    class_attribute :validators, instance_writer: false, default: {}

    class << self
      def validator(name, options)
        validators[name] = options
      end
    end

    validator :personal_details, form: "PersonalDetailsForm", unless: :apply_application_and_draft?
    validator :contact_details, form: "ContactDetailsForm", unless: :apply_application_and_draft?
    validator :diversity, form: "Diversities::FormValidator", unless: :apply_application_and_draft?
    validator :degrees, form: "DegreesForm", if: :validate_degree?
    validator :course_details, form: "CourseDetailsForm"
    validator :training_details, form: "TrainingDetailsForm"
    validator :trainee_data, form: "ApplyApplications::TraineeDataForm", if: :apply_application_and_draft?
    validator :schools, form: "Schools::FormValidator", if: :requires_training_partner?
    validator :funding, form: "Funding::FormValidator", if: :requires_funding?
    validator :iqts_country, form: "IqtsCountryForm", if: :requires_iqts_country?

    delegate :requires_training_partner?, :requires_degree?, :apply_application?,
             :requires_funding?, :requires_iqts_country?, :requires_placements?, to: :trainee

    validate :submission_ready

    def initialize(trainee:)
      @trainee = trainee
    end

    def validate_degree?
      !trainee.hesa_record? && !apply_application_and_draft? && requires_degree?
    end

    def apply_application_and_draft?
      apply_application? && trainee.draft?
    end

  private

    attr_reader :trainee

    def validator_keys
      keys = []
      all_validators.each do |validator, options|
        next if (condition = options[:if]) && !public_send(condition)
        next if (condition = options[:unless]) && public_send(condition)

        keys << validator
      end

      keys
    end

    def validator(progress_key)
      validator = all_validators[progress_key][:form].constantize
      if progress_key == :schools
        validator.new(trainee, non_search_validation: true)
      else
        validator.new(trainee)
      end
    end

    def submission_ready
      raise(NotImplementedError)
    end

    def all_validators
      defined?(extra_validators) ? validators.merge(extra_validators) : validators
    end
  end
end
