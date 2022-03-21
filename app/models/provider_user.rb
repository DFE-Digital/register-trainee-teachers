# frozen_string_literal: true

class ProviderUser < ApplicationRecord
  belongs_to :provider
  belongs_to :user

  validates :user, uniqueness: { scope: :provider_id }

  audited associated_with: :provider
end
