# frozen_string_literal: true

class NotFutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :future) if future_date?(value)
  end

private

  def future_date?(date)
    Date.iso8601(date).future?
  rescue Date::Error
    false
  end
end
