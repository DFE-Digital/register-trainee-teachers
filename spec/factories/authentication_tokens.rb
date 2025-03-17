# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    hashed_token { Digest::SHA256.hexdigest(SecureRandom.hex(10)) }
    enabled { true }
    provider
    created_by { provider.users.first }
    name { "test token" }
    expires_at { Faker::Date.forward(days: 30) }
  end
end
