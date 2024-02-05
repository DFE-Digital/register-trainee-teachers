# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    hashed_token { "MyString" }
    enabled { true }
    provider
    expires_at { "2024-02-05" }
  end
end
