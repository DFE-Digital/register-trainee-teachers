# frozen_string_literal: true

FactoryBot.define do
  factory :trainee_withdrawal_reason do
    association :trainee
    association :withdrawal_reason
  end
end
