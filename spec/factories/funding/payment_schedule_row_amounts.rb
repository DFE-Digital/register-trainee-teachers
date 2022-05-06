# frozen_string_literal: true

FactoryBot.define do
  factory :payment_schedule_row_amount, class: "Funding::PaymentScheduleRowAmount" do
    month { (1..12).to_a.sample }
    year { Time.zone.now.year }
    amount_in_pence { Faker::Number.number(digits: 6) }
  end
end
