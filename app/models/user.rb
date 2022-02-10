# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model

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
  validates :dttp_id, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }, unless: :system_admin?
  validates :dttp_id, uniqueness: true, if: :active_user?

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  def name
    "#{first_name} #{last_name}"
  end

  def active_user?
    User.exists?(dttp_id: dttp_id, discarded_at: nil)
  end

private

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
