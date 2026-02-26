# frozen_string_literal: true

FactoryBot.define do
  factory :feedback_item do
    satisfaction_level { "satisfied" }
    improvement_suggestion { "More documentation would be helpful" }
    name { "Jane Smith" }
    email { "user@example.com" }
  end
end
