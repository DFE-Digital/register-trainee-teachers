# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { ApiStubs::ApplyApi.application }
    invalid_data { {} }
    provider
  end
end
