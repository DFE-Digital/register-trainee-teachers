# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    name { PUBLISH_SUBJECT_SPECIALISM_MAPPING.keys.sample }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 5).upcase }

    trait :music do
      name { "Music" }
      code { "W3" }
    end
  end
end
