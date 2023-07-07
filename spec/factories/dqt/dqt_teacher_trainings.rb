# frozen_string_literal: true

FactoryBot.define do
  factory :dqt_training, class: "Dqt::TeacherTraining" do
    dqt_teacher
    programme_start_date { Faker::Date.in_date_period(month: 1) }
    programme_end_date { Faker::Date.in_date_period(month: 9) }
    programme_type { "ProviderLedPostgrad" }
    result { "InTraining" }
    provider_ukprn { Faker::Number.number(digits: 8) }
    active { true }
    hesa_id { Faker::Number.number(digits: 13) }
  end
end
