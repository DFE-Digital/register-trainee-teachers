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

    trait :development_condition do
      name { "Development condition" }
    end

    trait :learning_difficulty do
      name { "Learning difficulty" }
    end

    trait :long_standing_illness do
      name { "Long-standing illness" }
    end

    trait :mental_health_condition do
      name { "Mental health condition" }
    end

    trait :physical_disability_or_mobility_issue do
      name { "Physical disability or mobility issue" }
    end

    trait :social_or_communication_impairment do
      name { "Social or communication impairment" }
    end

    trait :other do
      name { "Other" }
    end

    trait :mental_health_condition do
      name { "Mental health condition" }
    end

    trait :no_known_disability do
      name { "No disabilities" }
    end
  end
end
