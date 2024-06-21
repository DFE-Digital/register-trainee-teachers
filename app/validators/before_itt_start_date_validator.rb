# frozen_string_literal: true

class BeforeIttStartDateValidator < ActiveModel::EachValidator
  include DatesHelper

  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :itt_start_date) if validate_itt_start_date?(record)
  end

private

  def validate_itt_start_date?(record)
    parsed_defer_date = Date.parse(record.defer_date)
    record.trainee_itt_start_date && date_before_itt_start_date?(parsed_defer_date, record.trainee_itt_start_date)
  end
end
