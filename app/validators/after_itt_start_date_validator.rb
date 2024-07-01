# frozen_string_literal: true

class AfterIttStartDateValidator < ActiveModel::EachValidator
  include DatesHelper

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :itt_start_date) if before_itt_start_date?(record, attribute)
  end

private

  def before_itt_start_date?(record, attribute)
    parsed_date = Date.parse(record.public_send(attribute))
    record.trainee_itt_start_date && date_before_itt_start_date?(parsed_date, record.trainee_itt_start_date)
  rescue Date::Error
    false
  end
end
