# frozen_string_literal: true

# == Schema Information
#
# Table name: authentication_tokens
#
#  id            :bigint           not null, primary key
#  expires_at    :date
#  hashed_token  :string
#  last_used_at  :datetime
#  name          :string           not null
#  revoked_at    :datetime
#  status        :string           default("active")
#  token_hash    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint
#  provider_id   :bigint           not null
#  revoked_by_id :bigint
#
# Indexes
#
#  index_authentication_tokens_on_created_by_id            (created_by_id)
#  index_authentication_tokens_on_expires_at               (expires_at)
#  index_authentication_tokens_on_hashed_token             (hashed_token) UNIQUE
#  index_authentication_tokens_on_provider_id              (provider_id)
#  index_authentication_tokens_on_revoked_by_id            (revoked_by_id)
#  index_authentication_tokens_on_status                   (status)
#  index_authentication_tokens_on_status_and_last_used_at  (status,last_used_at)
#  index_authentication_tokens_on_token_hash               (token_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (revoked_by_id => users.id)
#

class AuthenticationToken < ApplicationRecord
  SECRET_KEY = Rails.application.key_generator.generate_key("api-token:v1", 32)

  enum :status, {
    active: "active",
    expired: "expired",
    revoked: "revoked",
  } do
    event :revoke do
      before do
        self.revoked_by = Current.user
        self.revoked_at = Time.current
      end

      transition [:active] => :revoked
    end

    event :expire do
      transition [:active] => :expired
    end
  end

  attr_accessor :token

  belongs_to :provider
  belongs_to :created_by, class_name: "User"
  belongs_to :revoked_by, class_name: "User", optional: true

  scope :will_expire, lambda { |date = nil|
    if date.present?
      active.where(expires_at: ..date)
    else
      active.where.not(expires_at: nil)
    end
  }

  self.ignored_columns += ["enabled"]

  scope :by_status_and_last_used_at, -> { order(:status, last_used_at: :desc) }

  def self.create_with_random_token(
    name:,
    provider:,
    expires_at: nil,
    created_by:
  )
    begin
      token = "#{Rails.env}_" + SecureRandom.hex(32)
      token_hash = hash_token(token)
    end while exists?(token_hash:)

    create!(name:, provider:, created_by:, expires_at:, token_hash:, token:)
  end

  def self.legacy_hash_token(unhashed_token)
    Digest::SHA256.hexdigest(unhashed_token)
  end

  def self.hash_token(unhashed_token)
    OpenSSL::HMAC.hexdigest("SHA256", SECRET_KEY, unhashed_token)
  end

  def self.authenticate(unhashed_token)
    hmac_token = find_by(token_hash: hash_token(unhashed_token))

    return hmac_token if hmac_token.present?

    # Temp logic to convert existing tokens
    #
    token = find_by(hashed_token: legacy_hash_token(unhashed_token))
    token.presence&.update!(token_hash: hash_token(unhashed_token))
    token
  end

  def update_last_used_at!
    return if last_used_at&.today?

    update!(last_used_at: Time.current)
  end
end
