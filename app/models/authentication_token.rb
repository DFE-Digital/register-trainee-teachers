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

  before_save :hash_token, if: :hashed_token_changed?

  validates :hashed_token, presence: true, uniqueness: true

  def self.authenticate(unhashed_token)
    find_by(hashed_token: Digest::SHA256.hexdigest(unhashed_token))
  end

private

  def hash_token
    self.hashed_token = Digest::SHA256.hexdigest(hashed_token)
  end
end
