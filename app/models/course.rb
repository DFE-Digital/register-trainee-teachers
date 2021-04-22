# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :provider

  validates :code, presence: true, uniqueness: { scope: :provider_id }
  validates :name, presence: true
  validates :start_date, presence: true
  validates :level, presence: true
  validates :age_range, presence: true
  validates :duration_in_years, presence: true
  validates :qualification, presence: true
  validates :course_length, presence: true
  validates :route, presence: true

  enum level: {
    primary: 0,
    secondary: 1,
  }

  enum qualification: {
    qts: 0,
    pgce_with_qts: 1,
    pgde_with_qts: 2,
    pgce: 3,
    pgde: 4,
  }

  enum route: TRAINING_ROUTES_FOR_COURSE

  enum age_range: {
    AgeRange::THREE_TO_SEVEN_COURSE => 0,
    AgeRange::THREE_TO_ELEVEN_COURSE => 1,
    AgeRange::FIVE_TO_ELEVEN_COURSE => 2,
    AgeRange::SEVEN_TO_ELEVEN_COURSE => 3,
    AgeRange::SEVEN_TO_FOURTEEN_COURSE => 4,
    AgeRange::ELEVEN_TO_SIXTEEN_COURSE => 5,
    AgeRange::ELEVEN_TO_NINETEEN_COURSE => 6,
    AgeRange::FOURTEEN_TO_NINETEEN_COURSE => 7,
    AgeRange::FOURTEEN_TO_NINETEEN_COURSE => 8,
  }

  has_many :course_subjects
  has_many :subjects, through: :course_subjects

  def end_date
    return unless start_date
    return if duration_in_years.to_i.zero?

    (start_date + duration_in_years.years).prev_day
  end
end
