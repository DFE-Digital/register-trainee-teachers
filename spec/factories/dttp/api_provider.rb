# frozen_string_literal: true

FactoryBot.define do
  factory :api_provider, class: Hash do
    name { Faker::Name.last_name }
    dfe_ukprn { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    accountid { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
