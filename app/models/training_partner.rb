# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_partners
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  name         :string
#  record_type  :string           not null
#  ukprn        :citext
#  urn          :citext
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider_id  :bigint
#  school_id    :bigint
#
# Indexes
#
#  index_lead_partners_on_discarded_at  (discarded_at)
#  index_lead_partners_on_name          (name)
#  index_lead_partners_on_provider_id   (provider_id) UNIQUE
#  index_lead_partners_on_school_id     (school_id) UNIQUE
#  index_lead_partners_on_ukprn         (ukprn) UNIQUE
#  index_lead_partners_on_urn           (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class TrainingPartner < ApplicationRecord
  include Discard::Model

  RECORD_TYPES = [
    SCHOOL = "school",
    HEI = "hei",
    SCITT = "scitt",
  ].freeze
  enum(:record_type, RECORD_TYPES.to_h { |record_type| [record_type, record_type] })

  belongs_to :school, optional: true
  belongs_to :provider, optional: true

  has_many :training_partner_users, inverse_of: :training_partner
  has_many :users, through: :training_partner_users
  has_many :trainees

  validates :urn, presence: true, if: -> { school? }, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :record_type, presence: true, inclusion: { in: RECORD_TYPES }
  validates :ukprn, presence: true, if: -> { hei? }, uniqueness: { case_sensitive: false, allow_nil: true }
  validates :school, presence: true, if: -> { school? }
  validates :provider, presence: true, if: -> { hei? }

  def funding_payment_schedules
    school&.funding_payment_schedules || provider&.funding_payment_schedules
  end

  def funding_trainee_summaries
    school&.funding_trainee_summaries || provider&.funding_trainee_summaries
  end

  def name_and_code
    name
  end

  def self.find_by_ukprn_or_urn(str)
    return if str.blank?

    case str.length
    when 8
      find_by(ukprn: str)
    when 6
      find_by(urn: str)
    end
  end
end
