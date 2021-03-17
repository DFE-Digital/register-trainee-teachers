# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    provider
    sequence(:name) { |c| "Course #{c}" }
    code { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
  end
end
