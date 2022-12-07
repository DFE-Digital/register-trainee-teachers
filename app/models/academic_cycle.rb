# frozen_string_literal: true

class AcademicCycle < ApplicationRecord
  has_many :funding_methods

  validates :start_date, :end_date, presence: true
  validate :start_date_before_end_date

  scope :trainees_filter, -> { order(start_date: :desc).limit(3) }

  def self.for_year(year)
    where("extract(year from start_date) = ?", year.to_i).first
  end

  def self.for_date(date)
    where("end_date >= :date AND start_date <= :date", date:).first
  end

  def self.current
    for_date(Time.zone.now)
  end

  def trainees_starting
    trainee_scope = Trainee.where(start_academic_cycle: self)
    trainee_scope = trainee_scope.or(Trainee.where(start_academic_cycle: nil)) if current?
    trainee_scope
  end

  def trainees_ending
    trainee_scope = Trainee.where(end_academic_cycle: self)
    trainee_scope = trainee_scope.or(Trainee.where(end_academic_cycle: nil)) if current?
    trainee_scope
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
