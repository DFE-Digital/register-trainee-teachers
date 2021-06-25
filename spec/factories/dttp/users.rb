# frozen_string_literal: true

FactoryBot.define do
  factory :dttp_user, class: "Dttp::User" do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    dttp_id { SecureRandom.uuid }
    provider_dttp_id { SecureRandom.uuid }
  end
end
