# frozen_string_literal: true

# == Schema Information
#
# Table name: subject_specialisms
#
#  id                    :bigint           not null, primary key
#  hecos_code            :string
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  allocation_subject_id :bigint           not null
#
# Indexes
#
#  index_subject_specialisms_on_allocation_subject_id  (allocation_subject_id)
#  index_subject_specialisms_on_lower_name             (lower((name)::text)) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (allocation_subject_id => allocation_subjects.id)
#
class SubjectSpecialism < ApplicationRecord
  PRIMARY_SUBJECT_NAMES = [
    CourseSubjects::EARLY_YEARS_TEACHING,
    CourseSubjects::PRIMARY_TEACHING,
  ].freeze

  belongs_to :allocation_subject, inverse_of: :subject_specialisms

  scope :order_by_name, -> { order("LOWER(name)") }
  scope :secondary, -> { where.not(name: PRIMARY_SUBJECT_NAMES) }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
