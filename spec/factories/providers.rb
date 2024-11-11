# frozen_string_literal: true

FactoryBot.define do
  factory :provider, class: "Provider" do
    sequence :name do |n|
      "Provider #{n}"
    end
    code { Faker::Alphanumeric.alphanumeric(number: 3).upcase }
    ukprn { Faker::Number.number(digits: 8) }
    sequence(:accreditation_id, "1111")

    trait :unaccredited do
      accredited { false }
    end

    trait :teach_first do
      code { Provider::TEACH_FIRST_PROVIDER_CODE }
    end

    trait :ambition do
      code { Provider::AMBITION_PROVIDER_CODE }
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

    trait :with_dttp_id do
      dttp_id { SecureRandom.uuid }
    end

    trait :hei do
      accreditation_id { "1234" }
    end

    trait :scitt do
      accreditation_id { "5432" }
    end
  end
end
