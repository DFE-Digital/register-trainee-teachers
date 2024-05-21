# frozen_string_literal: true

class LeadPartner < ApplicationRecord
  RECORD_TYPES = [
    LEAD_SCHOOL = "lead_school",
    HEI = "hei",
  ].freeze
  enum record_type: RECORD_TYPES.to_h { |record_type| [record_type, record_type] }

  belongs_to :school, optional: true
  belongs_to :provider, optional: true

  validates :urn, presence: true, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }
  validates :ukprn, presence: true, if: -> { hei? }, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :school, presence: true, if: -> { lead_school? }
  validates :provider, presence: true, if: -> { hei? }
end
