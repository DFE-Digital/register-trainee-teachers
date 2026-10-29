# frozen_string_literal: true

# A relevant-degree mapping: for a given academic year and ITT subject, one
# degree subject (a HECoS code, within a CAH level 2 category) that counts as a
# "relevant degree" for funding. One record per HECoS code, each with a stable
# DRCAH reference. This is the reference list behind the Degree relevancy funding
# split. Managed from Funding management → Relevant degree CAH management.
# == Schema Information
#
# Table name: relevant_degree_mappings
#
#  id                    :bigint           not null, primary key
#  cah_level_1_code      :string           not null
#  cah_level_2_code      :string           not null
#  hecos_code            :string           not null
#  reference_number      :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  academic_cycle_id     :bigint           not null
#  allocation_subject_id :bigint           not null
#  created_by_id         :bigint
#
# Indexes
#
#  idx_relevant_degree_mappings_unique                      (academic_cycle_id,allocation_subject_id,hecos_code) UNIQUE
#  index_relevant_degree_mappings_on_academic_cycle_id      (academic_cycle_id)
#  index_relevant_degree_mappings_on_allocation_subject_id  (allocation_subject_id)
#  index_relevant_degree_mappings_on_created_by_id          (created_by_id)
#  index_relevant_degree_mappings_on_reference_number       (reference_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (allocation_subject_id => allocation_subjects.id)
#  fk_rails_...  (created_by_id => users.id)
#
class RelevantDegreeMapping < ApplicationRecord
  belongs_to :academic_cycle
  belongs_to :allocation_subject
  belongs_to :created_by, class_name: "User", optional: true

  validates :cah_level_1_code, :cah_level_2_code, :hecos_code, presence: true
  validates :hecos_code, uniqueness: { scope: %i[academic_cycle_id allocation_subject_id] }

  before_create :assign_reference_number

  # The human "DRCAH" reference (Degree Relevant CAH), a stable global sequence:
  # DRCAH001, DRCAH002, … Assigned on create, never reused after a delete.
  def reference
    return if reference_number.blank?

    format("DRCAH%03d", reference_number)
  end

  def cah_level_1_name = ::Funding::CahReference.level_1_name(cah_level_1_code)
  def cah_level_2_name = ::Funding::CahReference.level_2_name(cah_level_2_code)
  def hecos_name = ::Funding::CahReference.hecos_name(hecos_code)

private

  def assign_reference_number
    return if reference_number.present?

    self.reference_number = (RelevantDegreeMapping.maximum(:reference_number) || 0) + 1
  end
end
