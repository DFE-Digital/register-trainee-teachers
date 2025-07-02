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
        hesa_code_inclusion_message(record:, value:, valid_values:),
      )
    end
  end

private

  def hesa_code_inclusion_message(record:, value:, valid_values:)
    # Dynamically determine namespace from the record's class
    namespace_path = determine_namespace_path(record)
    
    I18n.t(
      "activemodel.errors.models.#{namespace_path}.attributes.inclusion",
      value: value,
      valid_values: valid_values.map { |v| "'#{v}'" }.join(", "),
    )
  end

  def determine_namespace_path(record)
    class_name = record.class.name
    
    case class_name
    when /Api::V20250Rc::/
      "api/v20250_rc/trainee_attributes"
    when /Api::V01::/
      "api/v01/trainee_attributes"  
    else
      # Fallback to v01 for safety
      "api/v01/trainee_attributes"
    end
  end
end
