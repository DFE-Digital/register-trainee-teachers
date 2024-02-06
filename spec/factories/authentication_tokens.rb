# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    hashed_token { Digest::SHA256.hexdigest(Time.zone.now.to_s) }
    enabled { true }
    provider
    expires_at { Faker::Date.forward(days: 30) }
  end
end
