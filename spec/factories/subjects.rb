# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    name { ["Primary with geography and history", "Primary with modern languages", "Primary with physical education", "Primary with science"].sample }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 2).upcase }
  end

  trait :music do
    name { "Music" }
    code { "W3" }
  end
end
