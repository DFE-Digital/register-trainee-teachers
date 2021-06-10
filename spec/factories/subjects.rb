# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:name) { |c| "Subject #{c}" }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 2).upcase }
  end

  trait :music do
    name { "Music" }
    code { "W3" }
  end
end
