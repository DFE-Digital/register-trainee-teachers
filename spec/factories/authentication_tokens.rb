FactoryBot.define do
  factory :authentication_token do
    hashed_token { "MyString" }
    enabled { true }
    association :provider
    expires_at { "2024-02-05" }
  end
end
