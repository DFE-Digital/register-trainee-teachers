# frozen_string_literal: true

class Subject < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :course_subjects
  has_many :courses, through: :course_subjects
end
