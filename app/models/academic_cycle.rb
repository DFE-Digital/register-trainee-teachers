# frozen_string_literal: true

# == Schema Information
#
# Table name: academic_cycles
#
#  id         :bigint           not null, primary key
#  end_date   :date             not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  academic_cycles_date_range  (tsrange((start_date)::timestamp without time zone, (end_date)::timestamp without time zone)) USING gist
#
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

  def self.previous
    for_date(1.year.ago)
  end

  def total_trainees
    trainees_starting.or(trainees_ending).or(Trainee.where("start_cycle.start_date < ?", start_date)
    .where("end_cycle.start_date > ?", start_date))
    .joins("INNER JOIN academic_cycles start_cycle ON trainees.start_academic_cycle_id = start_cycle.id")
    .joins("INNER JOIN academic_cycles end_cycle ON trainees.end_academic_cycle_id = end_cycle.id")
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

  def label(text = " to ")
    "#{start_year}#{text}#{start_year + 1}"
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
