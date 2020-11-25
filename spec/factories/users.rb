# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: User do
    dfe_sign_in_uid { SecureRandom.uuid }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }

    provider
  end
end
