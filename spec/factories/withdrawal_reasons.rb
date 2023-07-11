# frozen_string_literal: true

FactoryBot.define do
  factory :withdrawal_reason do
    name { WithdrawalReasons::COULD_NOT_GIVE_ENOUGH_TIME }

    trait :unknown do
      name { WithdrawalReasons::UNKNOWN }
    end

    trait :another_reason do
      name { WithdrawalReasons::ANOTHER_REASON }
    end
  end
end
