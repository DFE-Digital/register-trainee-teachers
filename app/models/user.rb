# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model

  belongs_to :provider, optional: true

  has_many :trainees, through: :provider

  scope :system_admins, -> { where(system_admin: true) }

  before_validation :sanitise_email

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :dttp_id, uniqueness: true, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }, unless: :system_admin?

  validate do |record|
    EmailFormatValidator.new(record).validate
  end

  audited associated_with: :provider

  def name
    "#{first_name} #{last_name}"
  end

private

  def sanitise_email
    self.email = email.gsub(/\s+/, "") unless email.nil?
  end
end
