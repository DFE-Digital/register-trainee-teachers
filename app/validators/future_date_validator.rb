# frozen_string_literal: true

class FutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :future) unless future_date?(value)
  end

private

  def future_date?(date)
    Date.iso8601(date.to_s).future?
  rescue Date::Error
    true
  end
end
