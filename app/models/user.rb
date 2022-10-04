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
  validates :email, uniqueness: { case_sensitive: false }, if: :active_user?

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  def name
    "#{first_name} #{last_name}"
  end

  def active_user?
    User.kept.exists?(email: email)
  end

  def search_values
    {
      id: id,
      name: name,
      synonyms: [email] + Array(provider_names) + Array(lead_school_names),
    }
  end

  def provider_names
    providers.map(&:name)
  end

  def lead_school_names
    lead_schools.map(&:name)
  end

private

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
