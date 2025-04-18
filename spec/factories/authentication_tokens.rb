# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    hashed_token { Digest::SHA256.hexdigest(SecureRandom.hex(10)) }
    provider
    created_by { provider.users.first }
    name { "test token" }
    last_used_at { Time.current }

    trait :will_expire do
      expires_at { 1.month.from_now }
    end

    trait :expired do
      status { :expired }

      expires_at { 1.day.ago }
    end

    trait :revoked do
      status { :revoked }

      revoked_at { Time.current }
      revoked_by { created_by }
    end
  end
end
