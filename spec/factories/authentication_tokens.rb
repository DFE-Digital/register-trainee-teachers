# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    hashed_token { Digest::SHA256.hexdigest(SecureRandom.hex(10)) }
    enabled { true }
    provider
    created_by { provider.users.first }
    name { "test token" }
    expires_at { Faker::Date.forward(days: 30) }
    last_used_at { Time.current }

    trait :expired do
      status { :expired }

      expires_at { 1.day.ago }
    end

    trait :revoked do
      status { :revoked }

      revoked_at { Time.current }
    end
  end
end
