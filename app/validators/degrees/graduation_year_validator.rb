# frozen_string_literal: true

class Degrees::GraduationYearValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    return if value.blank?

    record.errors.add(:graduation_year, :future) if value.to_i > next_year
    record.errors.add(:graduation_year, :invalid) unless value.to_i.between?(
      next_year - Degree::MAX_GRAD_YEARS, next_year
    )
  end

private

  def next_year
    Time.zone.now.year.next
  end
end
