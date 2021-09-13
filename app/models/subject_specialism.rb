# frozen_string_literal: true

class SubjectSpecialism < ApplicationRecord
  PRIMARY_SUBJECT_NAMES = [
    CourseSubjects::EARLY_YEARS_TEACHING,
    CourseSubjects::PRIMARY_TEACHING,
    CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS,
  ].freeze

  belongs_to :allocation_subject, inverse_of: :subject_specialisms

  scope :order_by_name, -> { order("LOWER(name)") }
  scope :secondary, -> { where.not(name: PRIMARY_SUBJECT_NAMES) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
