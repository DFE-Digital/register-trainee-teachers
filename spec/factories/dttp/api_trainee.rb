# frozen_string_literal: true

FactoryBot.define do
  factory :api_trainee, class: Hash do
    transient do
      dttp_id { SecureRandom.uuid }
      provider_dttp_id { SecureRandom.uuid }
    end
    contactid { dttp_id }
    _parentcustomerid_value { provider_dttp_id }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    emailaddress1 { "#{firstname}.#{lastname}@example.com" }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 65).strftime("%Y-%m-%d") }
    gendercode { 1 }
    address1_line1 { Faker::Address.street_address }
    address1_line2 { Faker::Address.street_name }
    address1_line3 { Faker::Address.city }
    address1_postalcode { Faker::Address.postcode }
    dfe_traineeid { "#{firstname}.#{lastname}.#{birthdate}" }
    _dfe_nationality_value { "d17d640e-5c62-e711-80d1-005056ac45bb" }
    dfe_trn { Faker::Number.number(digits: 7) }
    merged { false }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }
  end
end
