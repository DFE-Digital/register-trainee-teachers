# frozen_string_literal: true

FactoryBot.define do
  factory :provider_user do
    provider
    user
  end
end
