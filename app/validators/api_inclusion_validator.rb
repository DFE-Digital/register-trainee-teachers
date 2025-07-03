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
        self.class.hesa_code_inclusion_message(value: value, valid_values: valid_values),
      )
    end
  end
end
