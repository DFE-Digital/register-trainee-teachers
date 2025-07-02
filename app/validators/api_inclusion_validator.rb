# frozen_string_literal: true

class ApiInclusionValidator < ActiveModel::EachValidator
  include Api::ErrorMessageHelpers

  attr_reader :in, :valid_values

  MAX_VALID_VALUES_DISPLAYED = 10

  def initialize(options)
    super
    @in = options[:in]
    @valid_values = options[:valid_values] || @in
  end

  def validate_each(record, attribute, value)
    unless @in.include?(value)
      record.errors.add(
        attribute,
        self.class.hesa_code_inclusion_message(value:, valid_values:),
      )
    end
  end

private

  def hesa_code_inclusion_message(value:, valid_values:)
    if valid_values.count < MAX_VALID_VALUES_DISPLAYED
      I18n.t(
        "activemodel.errors.models.api/v20250_rc/trainee_attributes.attributes.inclusion",
        value: value,
        valid_values: valid_values.map { |v| "'#{v}'" }.join(", "),
      )
    else
      I18n.t(
        "activemodel.errors.models.api/v01/trainee_attributes.attributes.inclusion_with_truncated_list",
        value: value,
        valid_values: valid_values.first(MAX_VALID_VALUES_DISPLAYED).map { |v| "'#{v}'" }.join(", "),
      )
    end
  end
end
