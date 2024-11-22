# frozen_string_literal: true

FactoryBot.define do
  factory :sign_off do
    provider
    academic_cycle
    user
    performance_profile

    trait :previous_academic_cycle do
      academic_cycle { association :academic_cycle, :previous }
    end
  end
end
