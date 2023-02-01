# frozen_string_literal: true

# == Schema Information
#
# Table name: subjects
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subjects_on_code  (code) UNIQUE
#
class Subject < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :course_subjects
  has_many :courses, through: :course_subjects
end
