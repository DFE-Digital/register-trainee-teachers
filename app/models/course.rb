# frozen_string_literal: true

class Course < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true
  validates :start_date, presence: true
  validates :level, presence: true
  validates :min_age, presence: true
  validates :max_age, presence: true
  validates :duration_in_years, presence: true
  validates :qualification, presence: true
  validates :route, presence: true

  enum level: {
    COURSE_EDUCATION_PHASE_ENUMS[:primary] => 0,
    COURSE_EDUCATION_PHASE_ENUMS[:secondary] => 1,
  }

  enum qualification: {
    qts: 0,
    pgce_with_qts: 1,
    pgde_with_qts: 2,
    pgce: 3,
    pgde: 4,
  }

  enum route: TRAINING_ROUTES_FOR_COURSE
  enum study_mode: COURSE_STUDY_MODE_ENUMS

  belongs_to :provider, foreign_key: :accredited_body_code, primary_key: :code, inverse_of: :courses, optional: true

  has_many :trainees, ->(course) { unscope(:where).where(course_code: course.code) }, inverse_of: :trainee

  has_many :course_subjects

  # Order scope is critical - do not remove (see TeacherTrainingApi::ImportCourse#subjects)
  has_many :subjects, -> { order("course_subjects.id") }, through: :course_subjects

  def end_date
    return unless start_date
    return if duration_in_years.to_i.zero?

    (start_date + duration_in_years.years).prev_day
  end

  def age_range
    [min_age, max_age].compact
  end

  def age_range=(range)
    self.min_age, self.max_age = range
  end

  def subject_one
    subjects&.first
  end

  def subject_two
    subjects&.second
  end

  def subject_three
    subjects&.third
  end
end
