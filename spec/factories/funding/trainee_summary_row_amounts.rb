# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_summary_row_amount, class: "Funding::TraineeSummaryRowAmount" do
    association :row, factory: :trainee_summary_row

    trait :with_scholarship do
      payment_type { "scholarship" }
      tier { nil }
      amount { Faker::Number.number(digits: 6) }
      number_of_trainees { Faker::Number.number(digits: 2) }
    end

    trait :with_bursary do
      payment_type { "bursary" }
      tier { nil }
      amount { Faker::Number.number(digits: 6) }
      number_of_trainees { Faker::Number.number(digits: 2) }
    end

    trait :with_tiered_bursary do
      payment_type { "bursary" }
      tier { 2 }
      amount { Faker::Number.number(digits: 6) }
      number_of_trainees { Faker::Number.number(digits: 2) }
    end

    trait :with_grant do
      payment_type { "grant" }
      tier { nil }
      amount { Faker::Number.number(digits: 6) }
      number_of_trainees { Faker::Number.number(digits: 2) }
    end
  end
end
