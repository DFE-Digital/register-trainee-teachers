# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :users
  has_many :trainees

  validates :name, presence: true
  validates :dttp_id, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }

  audited
  has_associated_audits
end
