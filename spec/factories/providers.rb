# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: "Provider" do
    sequence :name do |n|
      "Provider #{n}"
    end
    dttp_id { SecureRandom.uuid }
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    ukprn { Faker::Number.number(digits: 8) }

    trait :teach_first do
      code { TEACH_FIRST_PROVIDER_CODE }
    end

    trait :with_courses do
      transient do
        courses_count { 1 }
        course_code { Faker::Alphanumeric.unique.alphanumeric(number: 4, min_alpha: 1).upcase }
      end

      after(:create) do |provider, evaluator|
        create_list(:course, evaluator.courses_count, code: evaluator.course_code, accredited_body_code: provider.code)
      end
    end
  end
end
