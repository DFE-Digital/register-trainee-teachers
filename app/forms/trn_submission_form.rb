# frozen_string_literal: true

class TrnSubmissionForm
  include ActiveModel::Model

  class_attribute :form_validators, instance_writer: false, default: {}

  class << self
    def trn_validator(name, options)
      form_validators[name] = options
    end
  end

  trn_validator :personal_details, form: "PersonalDetailsForm"
  trn_validator :contact_details, form: "ContactDetailsForm"
  trn_validator :diversity, form: "Diversities::FormValidator"
  trn_validator :degrees, form: "DegreesForm"
  trn_validator :course_details, form: "CourseDetailsForm"
  trn_validator :training_details, form: "TrainingDetailsForm"
  trn_validator :lead_school, form: "LeadSchoolForm", if: :requires_schools?

  delegate :requires_schools?, to: :trainee

  validate :submission_ready

  def initialize(trainee:)
    @trainee = trainee
  end

  def section_status(progress_key)
    progress_service(progress_key).status.parameterize(separator: "_").to_sym
  end

  def all_sections_complete?
    progress_keys.all? do |progress_key|
      progress_is_completed?(progress_key)
    end
  end

private

  attr_reader :trainee

  def validator(section)
    form_validators[section][:form].constantize
  end

  def submission_ready
    errors.add(:trainee, :incomplete) unless all_sections_complete?
  end

  def progress_service(progress_key)
    validator = validator(progress_key).new(trainee)
    progress_value = trainee.progress.public_send(progress_key)
    ProgressService.call(validator: validator, progress_value: progress_value)
  end

  def progress_is_completed?(progress_key)
    progress_service(progress_key).completed?
  end

  def progress_keys
    keys = []
    form_validators.each do |validator, options|
      next if (condition = options[:if]) && !public_send(condition)

      keys << validator
    end

    keys
  end
end
