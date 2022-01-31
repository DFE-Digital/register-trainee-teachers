# frozen_string_literal: true

FactoryBot.define do
  factory :api_trainee, class: Hash do
    transient do
      dttp_id { SecureRandom.uuid }
      provider_dttp_id { SecureRandom.uuid }
      nationality_name { Dttp::CodeSets::Nationalities::BRITISH }
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
    _dfe_nationality_value { Dttp::CodeSets::Nationalities::MAPPING[nationality_name][:entity_id] }
    dfe_trn { Faker::Number.number(digits: 7) }
    merged { false }
    createdon { Faker::Date.between(from: 2.years.ago, to: 2.days.ago).iso8601 }
    modifiedon { Faker::Date.between(from: 2.years.ago, to: 2.days.ago).iso8601 }
    dfe_husid { "1811499435078" }

    initialize_with { attributes.stringify_keys }
    to_create { |instance| instance }

    trait :with_uk_nationality do
      transient do
        nationality_name { Dttp::CodeSets::Nationalities::UK_NATIONALITIES.sample }
      end

      _dfe_nationality_value do
        Dttp::CodeSets::Nationalities::MAPPING.dig(nationality_name, :entity_id).presence ||
        Dttp::CodeSets::Nationalities::INACTIVE_MAPPING.dig(nationality_name, :entity_id)
      end
    end
  end
end
