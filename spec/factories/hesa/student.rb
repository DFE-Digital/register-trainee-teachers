# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_student, class: "Hesa::Student" do
    ukprn { Faker::Number.number(digits: 8) }
  end
end
