# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_methods
#
#  id                  :bigint           not null, primary key
#  amount              :integer
#  availability        :integer          default(0), not null
#  degree_relevance    :integer
#  funding_method      :string
#  funding_type        :integer
#  reference_number    :integer
#  school_disadvantage :integer
#  training_route      :string           not null
#  training_year       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  academic_cycle_id   :bigint
#
# Indexes
#
#  idx_on_academic_cycle_id_reference_number_51dbb7359c  (academic_cycle_id,reference_number) UNIQUE
#  index_funding_methods_on_academic_cycle_id            (academic_cycle_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#
class FundingMethod < ApplicationRecord
  belongs_to :academic_cycle

  has_many :funding_method_subjects, inverse_of: :funding_method, dependent: :destroy
  has_many :allocation_subjects, through: :funding_method_subjects, inverse_of: :funding_methods

  validates :training_route, presence: true, inclusion: { in: TRAINING_ROUTE_ENUMS.values }
  validates :amount, presence: true, if: :available?
  validates :amount, absence: true, if: :not_available?

  enum :funding_type, FUNDING_TYPES

  before_create :assign_reference_number

  # The human "IFR" reference: IFR + the cycle's 2-digit start year + the stored
  # per-cycle sequence (e.g. IFR27001). Stable once assigned.
  def reference
    return if reference_number.blank? || academic_cycle.nil?

    format("IFR%02d%03d", academic_cycle.start_year % 100, reference_number)
  end

  # Split-amount bursaries where the amount depends on whether the trainee's
  # degree is relevant to the course subject. Nil = the amount applies
  # regardless of degree relevance (the common case). See the relevant-degree
  # bursary proposal.
  enum :degree_relevance, { relevant: 0, unrelated: 1 }, prefix: :degree

  # Split-amount funding where the amount depends on whether the employing
  # school is a disadvantaged/special school. Nil = the amount applies
  # regardless of the school (the common case). Composes with degree_relevance:
  # a record may be split on both axes.
  enum :school_disadvantage, { disadvantaged: 0, non_disadvantaged: 1 }, prefix: :school

  # A record can say the funding type isn't available for its criterion, for
  # example no bursary for an unrelated degree. Those records have no amount.
  enum :availability, { available: 0, not_available: 1 }

  # "Bursary not available", "Scholarship not available" or "Grant not available".
  def self.not_available_label(funding_type)
    "#{funding_type.to_s.humanize} not available"
  end

  def not_available_label = self.class.not_available_label(funding_type)

private

  # Next sequence within the academic cycle (max + 1), so numbers never reuse
  # after a delete. Assigned to seeded, wizard-created and factory records alike.
  def assign_reference_number
    return if reference_number.present? || academic_cycle.nil?

    max = academic_cycle.funding_methods.maximum(:reference_number) || 0
    self.reference_number = max + 1
  end
end
