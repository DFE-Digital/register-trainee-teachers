# frozen_string_literal: true

module Submissions
  class BaseValidator
    include ActiveModel::Model

    class_attribute :form_validators, instance_writer: false, default: {}

    class << self
      def trn_validator(name, options)
        form_validators[name] = options
      end
    end

    trn_validator :personal_details, form: "PersonalDetailsForm", unless: :apply_application_and_draft?
    trn_validator :contact_details, form: "ContactDetailsForm", unless: :apply_application_and_draft?
    trn_validator :diversity, form: "Diversities::FormValidator", unless: :apply_application_and_draft?
    trn_validator :degrees, form: "DegreesForm", if: :validate_degree?
    trn_validator :course_details, form: "CourseDetailsForm"
    trn_validator :training_details, form: "TrainingDetailsForm"
    trn_validator :trainee_data, form: "ApplyApplications::TraineeDataForm", if: :apply_application_and_draft?
    trn_validator :schools, form: "Schools::FormValidator", if: :requires_schools?
    trn_validator :funding, form: "Funding::FormValidator"

    delegate :requires_schools?, :requires_degree?, :apply_application?, to: :trainee

    validate :submission_ready

    def initialize(trainee:)
      @trainee = trainee
    end

    def validate_degree?
      !apply_application_and_draft? && requires_degree?
    end

    def apply_application_and_draft?
      apply_application? && trainee.draft?
    end

  private

    attr_reader :trainee

    def validator_keys
      keys = []
      form_validators.each do |validator, options|
        next if (condition = options[:if]) && !public_send(condition)
        next if (condition = options[:unless]) && public_send(condition)

        keys << validator
      end

      keys
    end

    def validator(progress_key)
      validator = form_validators[progress_key][:form].constantize
      if progress_key == :schools
        validator.new(trainee, non_search_validation: true)
      else
        validator.new(trainee)
      end
    end

    def submission_ready
      raise(NotImplementedError)
    end
  end
end
