# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_school_designations
#
#  id                :bigint           not null, primary key
#  designation       :enum             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint           not null
#  school_id         :bigint           not null
#
# Indexes
#
#  idx_funding_school_designations_unique                  (school_id,academic_cycle_id) UNIQUE
#  index_funding_school_designations_on_academic_cycle_id  (academic_cycle_id)
#  index_funding_school_designations_on_school_id          (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (school_id => schools.id)
#
class FundingSchoolDesignation < ApplicationRecord
  belongs_to :school
  belongs_to :academic_cycle

  enum :designation, { disadvantaged: "disadvantaged", special: "special" }

  validates :designation, presence: true
  validates :school_id, uniqueness: { scope: :academic_cycle_id }
end
