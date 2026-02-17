# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    satisfaction_level { "satisfied" }
    improvement_suggestion { "More documentation would be helpful" }
    email { "user@example.com" }
  end
end
