# frozen_string_literal: true

class CourseSubject < ApplicationRecord
  belongs_to :course
  belongs_to :subject

  validates_uniqueness_of :subject_id, :scope => :course_id

  # validates :course, presence: true, uniqueness: { scope: :subject_id }
end
