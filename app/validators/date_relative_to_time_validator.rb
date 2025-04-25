# frozen_string_literal: true

class DateRelativeToTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, error_type) unless date_in_expected_period?(value)
  end

private

  def date_in_expected_period?(date)
    is_future = parse_and_check_future(date)

    options[:future] ? is_future : !is_future
  rescue Date::Error
    true
  end

  def parse_and_check_future(date)
    Date.iso8601(date.to_s).future?
  end

  def error_type
    options[:future] ? :future : :not_future
  end
end
