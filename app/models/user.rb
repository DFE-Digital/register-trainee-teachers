# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include PgSearch::Model

  has_many :provider_users, inverse_of: :user
  has_many :providers, through: :provider_users

  has_many :lead_school_users
  has_many :lead_schools, through: :lead_school_users

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
