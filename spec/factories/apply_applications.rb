# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { ApiStubs::ApplyApi.application }
    invalid_data { {} }
    provider

    trait :with_invalid_data do
      invalid_data { { "degrees" => { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s => { institution: "University of Warwick" } } } }
    end

    trait :with_multiple_invalid_data do
      invalid_data { { "degrees" => { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s => { institution: "University of Warwick", subject: "History1" } } } }
    end
  end
end
