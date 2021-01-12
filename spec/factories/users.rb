# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    dfe_sign_in_uid { SecureRandom.uuid }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    dttp_id { SecureRandom.uuid }

    provider

    trait :system_admin do
      system_admin { true }
    end
  end
end
