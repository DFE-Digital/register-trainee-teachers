# frozen_string_literal: true

# == Schema Information
#
# Table name: authentication_tokens
#
#  id           :bigint           not null, primary key
#  enabled      :boolean          default(TRUE)
#  expires_at   :date
#  hashed_token :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider_id  :bigint
#
# Indexes
#
#  index_authentication_tokens_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#

class AuthenticationToken < ApplicationRecord
  belongs_to :provider

  validates :hashed_token, presence: true, uniqueness: true

  def self.create_with_random_token(attributes = {})
    token = SecureRandom.hex(10)
    hashed_token = hash_token(token)

    create(attributes.merge(hashed_token:))
    token
  end

  def self.hash_token(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.authenticate(unhashed_token)
    find_by(hashed_token: Digest::SHA256.hexdigest(unhashed_token))
  end
end
