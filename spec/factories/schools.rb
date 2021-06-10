# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    urn { Faker::Number.unique.number(digits: 7) }
    name { Faker::University.name }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }
    lead_school { false }

    trait :open do
      open_date { Faker::Date.in_date_period }
    end

    trait :closed do
      open_date { Faker::Date.in_date_period }
      close_date { Faker::Date.in_date_period }
    end

    trait :lead do
      lead_school { true }
    end
  end
end
