# frozen_string_literal: true

class ApiInclusionValidator < ActiveModel::EachValidator
  include Api::ErrorMessageHelpers

  attr_reader :in, :valid_values

  def initialize(options)
    super
    @in = options[:in]
    @valid_values = options[:valid_values] || @in
  end

  def validate_each(record, attribute, value)
    unless @in.include?(value)
      record.errors.add(
        attribute,
        hesa_code_inclusion_message(value:, valid_values:),
      )
    end
  end

private

  def hesa_code_inclusion_message(value:, valid_values:)
    I18n.t(
      "activemodel.errors.models.api/v01/trainee_attributes.attributes.inclusion",
      value: value,
      valid_values: valid_values.map { |v| "'#{v}'" }.join(", "),
    )
  end
end
