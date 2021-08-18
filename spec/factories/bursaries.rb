# frozen_string_literal: true

FactoryBot.define do
  factory :bursary do
    training_route { TRAINING_ROUTES_FOR_TRAINEE.keys.sample }
    amount { Faker::Number.number(digits: 5) }

    trait :with_bursary_subjects do
      after(:create) do |bursary, _|
        create_list(:bursary_subject, 2, bursary: bursary)
      end
    end
  end
end
