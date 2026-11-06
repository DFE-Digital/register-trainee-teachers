# frozen_string_literal: true

# A school recorded, for a given academic year, as a disadvantaged or special
# school for funding purposes. It is the list that decides whether the
# "Disadvantaged school/special school" funding amount applies to a trainee's
# employing school (see FundingMethod#school_disadvantage). Managed from
# Funding management → Funding schools management.
# == Schema Information
#
# Table name: funding_school_designations
#
#  id                :bigint           not null, primary key
#  designation       :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint           not null
#  created_by_id     :bigint
#  school_id         :bigint           not null
#
# Indexes
#
#  idx_funding_school_designations_unique                  (school_id,academic_cycle_id) UNIQUE
#  index_funding_school_designations_on_academic_cycle_id  (academic_cycle_id)
#  index_funding_school_designations_on_created_by_id      (created_by_id)
#  index_funding_school_designations_on_school_id          (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (school_id => schools.id)
#
class FundingSchoolDesignation < ApplicationRecord
  belongs_to :school
  belongs_to :academic_cycle
  belongs_to :created_by, class_name: "User", optional: true

  enum :designation, { disadvantaged: 0, special: 1 }

  validates :designation, presence: true
  # One designation per school per year.
  validates :school_id, uniqueness: { scope: :academic_cycle_id }

  def designation_label
    { "disadvantaged" => "Disadvantaged school", "special" => "Special school" }.fetch(designation, designation)
  end
end
