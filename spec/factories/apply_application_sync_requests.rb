# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application_sync_request do
    trait :successful do
      successful { true }
      response_code { 200 }
    end

    trait :unsuccessful do
      successful { false }
      response_code { 500 }
    end
  end
end
