# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { ApiStubs::ApplyApi.application }
    provider
  end
end
