# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    sequence(:urn) { |n| "urn_#{n}" }
    sequence(:name) { |n| "School #{n}" }
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
  end
end
