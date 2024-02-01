# frozen_string_literal: true

class DateOfBirthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !value.is_a?(Date)
      record.errors.add(attribute, :invalid)
    elsif value > Time.zone.today
      record.errors.add(attribute, :future)
    elsif value.year.digits.length != 4
      record.errors.add(attribute, :invalid_year)
    elsif value > 16.years.ago
      record.errors.add(attribute, :under16)
    elsif value < 100.years.ago
      record.errors.add(attribute, :past)
    end
  end
end
