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

    trait :provider do
      name { WithdrawalReasons::PROVIDER_REASONS.first }
    end

    trait :trainee do
      name { WithdrawalReasons::TRAINEE_REASONS.first }
    end

    trait :safeguarding do
      name { WithdrawalReasons::SAFEGUARDING_CONCERNS }
    end

    trait :with_all_reasons do
      to_create do |_instance|
        WithdrawalReasons::SEED.each do |seed|
          FactoryBot.create(:withdrawal_reason, name: seed[:name])
        end
      end
    end
  end
end
