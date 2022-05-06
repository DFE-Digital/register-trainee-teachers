# frozen_string_literal: true

FactoryBot.define do
  factory :payment_schedule_row, class: "Funding::PaymentScheduleRow" do
    sequence(:description) { |number| "Payment Schedule #{number}" }

    amounts { [build(:payment_schedule_row_amount)] }
  end
end
