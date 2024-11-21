# frozen_string_literal: true

FactoryBot.define do
  factory :sign_off do
    provider
    academic_cycle
    user
    sign_off_type { "MyString" }

    trait :performance_profile do
      sign_off_type { "performance_profile" }
    end

    trait :census do
      sign_off_type { "census" }
    end

    trait :previous_academic_cycle do
      academic_cycle { association :academic_cycle, :previous }
    end
  end
end
