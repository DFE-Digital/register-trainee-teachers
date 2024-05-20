# frozen_string_literal: true

class LeadPartner < ApplicationRecord
  RECORD_TYPES = [
    LEAD_SCHOOL = "lead_school",
    HEI = "hei",
  ].freeze
  enum record_type: RECORD_TYPES.to_h { |record_type| [record_type, record_type] }

  belongs_to :school, optional: true
  belongs_to :provider, optional: true
end
