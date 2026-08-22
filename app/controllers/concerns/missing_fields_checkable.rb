# frozen_string_literal: true

module MissingFieldsCheckable
  extend ActiveSupport::Concern

  included do
    helper_method :missing_fields, :required_missing_fields
  end

private

  def missing_fields
    @missing_fields ||= missing_data_validator.missing_fields
  end

  def required_missing_fields
    @required_missing_fields ||= missing_fields.excluding(Submissions::MissingDataValidator::OPTIONAL_FIELDS)
  end

  def missing_data_validator
    @missing_data_validator ||= Submissions::MissingDataValidator.new(trainee:)
  end
end
