# frozen_string_literal: true

module ApplyApplications
  class TraineeDataForm
    include ActiveModel::Model

    class_attribute :form_validators, instance_writer: false, default: {}

    class << self
      def validator(name, options)
        form_validators[name] = options
      end
    end

    validator :personal_details, form: "PersonalDetailsForm"
    validator :contact_details, form: "ContactDetailsForm"
    validator :diversity, form: "Diversities::FormValidator"
    validator :degrees, form: "DegreesForm", if: :validate_degree?

    delegate :apply_application?, to: :trainee

    validate :submission_ready

    attr_accessor :mark_as_reviewed, :trainee, :include_degree_id

    def validate_degree?
      trainee.requires_degree?
    end

    def initialize(trainee, include_degree_id: false)
      @trainee = trainee
      @include_degree_id = include_degree_id
    end

    def save
      return unless valid?

      trainee.progress.personal_details = true
      trainee.progress.contact_details = true
      trainee.progress.diversity = true
      trainee.progress.degrees = true if trainee.requires_degree?
      trainee.progress.trainee_data = true
      Trainees::Update.call(trainee:)
    end

    def progress_status(progress_key)
      return :not_provided if trainee.apply_application? && !progress_service(progress_key).started?

      progress_service(progress_key).status.parameterize(separator: "_").to_sym
    end

    def progress
      validator_keys.all? { |section_key| trainee.progress.public_send(section_key) }
    end

    def fields
      validator_keys.map do |section|
        validator_obj(section).fields
      end.inject(:merge)
    end

    def missing_fields
      validator_keys.map do |section|
        if section == :degrees
          validator_obj(section).missing_fields(include_degree_id:)
        else
          validator_obj(section).missing_fields
        end
      end
    end

    def display_type(section_key)
      if section_key == :degrees
        progress_status(section_key) == :not_provided ? :collapsed : :expanded
      else
        :expanded
      end
    end

  private

    def all_forms_valid?
      validator_keys.all? do |section|
        validator_obj(section).valid?
      end
    end

    def validator_obj(section)
      @validator_obj ||= {}
      @validator_obj[section] ||= validator(section).new(trainee)
    end

    def submission_ready
      errors.add(:trainee, :incomplete) unless all_forms_valid?
    end

    def progress_service(progress_key)
      progress_value = trainee.progress.public_send(progress_key)
      ProgressService.call(
        validator: validator_obj(progress_key),
        progress_value: progress_value,
      )
    end

    def validator(section)
      form_validators[section][:form].constantize
    end

    def validator_keys
      keys = []
      form_validators.each do |validator, options|
        next if (condition = options[:if]) && !public_send(condition)
        next if (condition = options[:unless]) && public_send(condition)

        keys << validator
      end

      keys
    end
  end
end
