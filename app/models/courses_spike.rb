# frozen_string_literal: true

class CoursesSpike < ApplicationRecord
  belongs_to :provider

  validates :name, presence: true
  validates :level, presence: true
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

  enum route: TRAINING_ROUTES

  has_many :course_subjects
  has_many :subjects, through: :course_subjects

  def end_date
    return unless start_date
    return if duration_in_years.to_i.zero?

    (start_date + duration_in_years.years).prev_day
  end
end
