# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  dfe_sign_in_uid       :string
#  discarded_at          :datetime
#  email                 :string           not null
#  first_name            :string           not null
#  last_name             :string           not null
#  last_signed_in_at     :datetime
#  otp_secret            :string
#  read_only             :boolean          default(FALSE)
#  system_admin          :boolean          default(FALSE)
#  welcome_email_sent_at :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  dttp_id               :uuid
#
# Indexes
#
#  index_unique_active_dttp_users  (dttp_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_unique_active_users       (email) UNIQUE WHERE (discarded_at IS NULL)
#  index_users_on_dfe_sign_in_uid  (dfe_sign_in_uid) UNIQUE
#  index_users_on_discarded_at     (discarded_at)
#
class User < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  has_many :provider_users, inverse_of: :user
  has_many :providers, through: :provider_users

  has_many :lead_school_users
  has_many :lead_schools, through: :lead_school_users

  has_many :bulk_update_recommendations_uploads, class_name: "BulkUpdate::RecommendationsUpload"

  scope :order_by_last_name, -> { order(:last_name) }
  scope :system_admins, -> { where(system_admin: true) }

  before_validation :sanitise_email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }, if: :active_user?

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  encrypts :otp_secret

  pg_search_scope :search,
                  against: %i[first_name last_name email],
                  associated_against: { providers: [:name], lead_schools: [:name] },
                  using: { trigram: { word_similarity: true } }

  def name
    "#{first_name} #{last_name}"
  end

  def active_user?
    User.kept.exists?(email:)
  end

  # This is used as a secret for this user to
  # generate their OTPs, keep it private.
  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random(16)
  end

  def generate_otp_secret!(regenerate: false)
    return unless otp_secret.blank? || regenerate

    generate_otp_secret
    save!
  end

private

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
