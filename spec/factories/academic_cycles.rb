# frozen_string_literal: true

FactoryBot.define do
  factory :academic_cycle do
    start_date { Faker::Date.in_date_period(month: 9) }
    end_date { Faker::Date.in_date_period(month: 8, year: Faker::Date.in_date_period.year + 1) }
  end
end
