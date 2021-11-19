# frozen_string_literal: true

class AcademicCycle < ApplicationRecord
  validates :start_date, :end_date, presence: true

  validate :start_date_before_end_date

private

  def start_date_before_end_date
    return unless dates_available?

    if start_date > end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def dates_available?
    start_date && end_date
  end
end
