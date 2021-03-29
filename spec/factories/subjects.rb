# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:name) { |c| "Subject #{c}" }
    code { Faker::Alphanumeric.alphanumeric(number: 2).upcase }
  end
end
