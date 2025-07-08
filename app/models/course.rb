# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id                     :bigint           not null, primary key
#  accredited_body_code   :string           not null
#  code                   :string           not null
#  course_length          :string
#  duration_in_years      :integer          not null
#  full_time_end_date     :date
#  full_time_start_date   :date
#  level                  :integer          not null
#  max_age                :integer
#  min_age                :integer
#  name                   :string           not null
#  part_time_end_date     :date
#  part_time_start_date   :date
#  published_start_date   :date             not null
#  qualification          :integer          not null
#  recruitment_cycle_year :integer
#  route                  :integer          not null
#  study_mode             :integer
#  summary                :string           not null
#  uuid                   :uuid
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_courses_on_code_and_accredited_body_code  (code,accredited_body_code)
#  index_courses_on_recruitment_cycle_year         (recruitment_cycle_year)
#  index_courses_on_uuid                           (uuid) UNIQUE
#
class Course < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true
  validates :published_start_date, presence: true
  validates :level, presence: true
  validates :duration_in_years, presence: true
  validates :qualification, presence: true
  validates :route, presence: true

  enum :level, {
    COURSE_EDUCATION_PHASE_ENUMS[:primary] => 0,
    COURSE_EDUCATION_PHASE_ENUMS[:secondary] => 1,
  }

  enum :qualification, {
    qts: 0,
    pgce_with_qts: 1,
    pgde_with_qts: 2,
    pgce: 3,
    pgde: 4,
    qts_with_undergraduate_degree: 5,
  }

  enum :route, TRAINING_ROUTES_FOR_COURSE
  enum :study_mode, COURSE_STUDY_MODE_ENUMS

  belongs_to :provider, foreign_key: :accredited_body_code, primary_key: :code, inverse_of: :courses, optional: true

  has_many :trainees, ->(course) { unscope(:where).where(course_uuid: course.uuid) }, inverse_of: :published_course

  has_many :course_subjects

  # Order scope is critical - do not remove (see TeacherTrainingApi::ImportCourse#subjects)
  has_many :subjects, -> { order("course_subjects.id") }, through: :course_subjects

  def start_date
    public_send("#{study_mode}_start_date") if study_mode && study_mode != COURSE_STUDY_MODES[:full_time_or_part_time]
  end

  def end_date
    public_send("#{study_mode}_end_date") if study_mode && study_mode != COURSE_STUDY_MODES[:full_time_or_part_time]
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

  def single_study_mode?
    study_mode != COURSE_STUDY_MODES[:full_time_or_part_time]
  end
end
