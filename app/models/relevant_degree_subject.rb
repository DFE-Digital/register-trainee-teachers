# frozen_string_literal: true

# == Schema Information
#
# Table name: relevant_degree_subjects
#
#  id                    :bigint           not null, primary key
#  hecos_code            :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  academic_cycle_id     :bigint           not null
#  allocation_subject_id :bigint           not null
#
# Indexes
#
#  idx_relevant_degree_subjects_unique                      (academic_cycle_id,allocation_subject_id,hecos_code) UNIQUE
#  index_relevant_degree_subjects_on_academic_cycle_id      (academic_cycle_id)
#  index_relevant_degree_subjects_on_allocation_subject_id  (allocation_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (allocation_subject_id => allocation_subjects.id)
#
class RelevantDegreeSubject < ApplicationRecord
  PLACEHOLDER_HECOS_CODES = %w[999998 999999].freeze

  belongs_to :academic_cycle
  belongs_to :allocation_subject

  normalizes :hecos_code, with: ->(code) { code.strip }

  validates :hecos_code,
    presence: true,
    uniqueness: { scope: %i[academic_cycle_id allocation_subject_id] },
    inclusion: { in: ->(_) { ReferenceData::DEGREE_SUBJECTS.hesa_codes }, allow_blank: true },
    exclusion: { in: PLACEHOLDER_HECOS_CODES }
end
