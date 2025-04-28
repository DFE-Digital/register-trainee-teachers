# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    Date.iso8601(value.to_s)
  rescue Date::Error
    record.errors.add(attribute, :invalid)
  end
end
