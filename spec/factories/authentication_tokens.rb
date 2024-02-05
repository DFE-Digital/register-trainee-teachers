FactoryBot.define do
  factory :authentication_token do
    hashed_token { "MyString" }
    enabled { false }
    provider_id { 1 }
    expires_at { "2024-02-05" }
  end
end
