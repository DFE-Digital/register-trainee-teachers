# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_partners
#
#  id          :bigint           not null, primary key
#  name        :string
#  record_type :string           not null
#  ukprn       :citext
#  urn         :citext
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint
#  school_id   :bigint
#
# Indexes
#
#  index_lead_partners_on_name         (name)
#  index_lead_partners_on_provider_id  (provider_id)
#  index_lead_partners_on_school_id    (school_id)
#  index_lead_partners_on_ukprn        (ukprn) UNIQUE
#  index_lead_partners_on_urn          (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class LeadPartner < ApplicationRecord
  RECORD_TYPES = [
    LEAD_SCHOOL = "lead_school",
    HEI = "hei",
  ].freeze
  enum record_type: RECORD_TYPES.to_h { |record_type| [record_type, record_type] }

  belongs_to :school, optional: true
  belongs_to :provider, optional: true

  has_many :lead_partner_users, inverse_of: :lead_partner
  has_many :users, through: :lead_partner_users

  validates :urn, presence: true, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }
  validates :ukprn, presence: true, if: -> { hei? }, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :school, presence: true, if: -> { lead_school? }
  validates :provider, presence: true, if: -> { hei? }
end
