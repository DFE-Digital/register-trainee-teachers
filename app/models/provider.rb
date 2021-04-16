# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :users
  has_many :trainees
  has_many :apply_applications
  has_many :courses

  validates :name, presence: true
  validates :dttp_id, uniqueness: true, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }
  validates :code, format: { with: /\A[A-Z0-9]+\z/i }

  alias_attribute :ukprn, :code

  def code=(cde)
    self[:code] = cde.to_s.upcase
  end

  audited
  has_associated_audits
end
