# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_withdrawal_reason do
    trainee
    withdrawal_reason
  end
end
