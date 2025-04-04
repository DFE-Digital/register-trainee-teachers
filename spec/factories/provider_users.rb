# frozen_string_literal: true

FactoryBot.define do
  factory :provider_user do
    provider

    user factory: %i[user with_no_organisation_in_db]
  end
end
