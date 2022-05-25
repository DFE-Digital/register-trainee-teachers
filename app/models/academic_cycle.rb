# frozen_string_literal: true

class AcademicCycle < ApplicationRecord
  has_many :funding_methods

  validates :start_date, :end_date, presence: true
  validate :start_date_before_end_date

  scope :trainees_filter, -> { order(start_date: :desc).limit(3) }

  def self.for_year(year)
    from_date = Date.new(year.to_i, 1, 1)
    to_date = from_date.end_of_year
    where(start_date: from_date..to_date).first
  end

  def self.for_date(date)
    where("end_date >= :date AND start_date <= :date", date: date).first
  end

  def self.current
    for_date(Time.zone.now)
  end

  def trainees_starting
    query = <<~SQL
      COALESCE(commencement_date, itt_start_date) BETWEEN :start_date AND :end_date
    SQL

    result_scope = Trainee.where(query, start_date: start_date, end_date: end_date)

    if current?
      result_scope = result_scope.or(Trainee.where(commencement_date: nil, itt_start_date: nil))
    end

    result_scope.kept
  end

  def start_year
    start_date.year
  end

  def end_year
    end_date.year
  end

  def label
    "#{start_year} to #{start_year + 1}"
  end

  def current?
    Time.zone.now >= start_date && Time.zone.now <= end_date
  end

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
