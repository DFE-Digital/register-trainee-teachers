# frozen_string_literal: true

FactoryBot.define do
  factory :disability do
    sequence(:name) { |n| "disability #{n}" }
    description { "some disability text" }

    trait :blind do
      name { "Blind" }
    end

    trait :deaf do
      name { "Deaf" }
    end

    trait :other do
      name { "Other" }
    end

    trait :mental_health_condition do
      name { "Mental health condition" }
    end
  end
end
