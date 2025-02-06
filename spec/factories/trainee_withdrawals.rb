# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_withdrawal, class: "TraineeWithdrawal" do
    trainee
    date { Time.zone.local(2024, 11, 18) }
    trigger { :provider }
    another_reason { "Not enough coffee" }
    future_interest { :yes }
  end

  trait :untriggered do
    date { nil }
    trigger { nil }
    another_reason { nil }
    future_interest { nil }
  end
end
