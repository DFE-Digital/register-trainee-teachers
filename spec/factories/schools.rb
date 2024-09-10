# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    urn { Faker::Number.unique.number(digits: 6) }
    name { Faker::Educator.secondary_school }
    town { Faker::Address.city }
    postcode { Faker::Address.postcode }

    trait :open do
      open_date { Faker::Date.in_date_period }
    end

    trait :closed do
      open_date { Faker::Date.in_date_period }
      close_date { Faker::Date.in_date_period }
    end

    trait :with_employing_trainees do
      transient do
        employing_trainees_count { 2 }
      end

      after(:create) do |school, evaluator|
        create_list(:trainee, evaluator.employing_trainees_count, employing_school_id: school.id)
      end
    end
  end
end
