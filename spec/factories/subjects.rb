# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    code { Faker::Alphanumeric.unique.alphanumeric(number: 2).upcase }
    name { Dttp::CodeSets::CourseSubjects::MAPPING.keys.sample }
  end

  trait :music do
    name { "Music" }
    code { "W3" }
  end
end
