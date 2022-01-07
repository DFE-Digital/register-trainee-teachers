# frozen_string_literal: true

class ProviderUser < ApplicationRecord
  belongs_to :provider
  belongs_to :user

  validates :provider, presence: true
  validates :user, presence: true, uniqueness: { scope: :provider_id }

  audited associated_with: :provider
end
