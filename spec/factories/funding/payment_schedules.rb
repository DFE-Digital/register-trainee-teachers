# frozen_string_literal: true

FactoryBot.define do
  factory :payment_schedule, class: "Funding::PaymentSchedule" do
    trait :for_provider do
      payable { |p| p.association(:provider) }
    end

    trait :for_school do
      payable { |p| p.association(:school) }
    end

    rows { [build(:payment_schedule_row)] }
  end
end
