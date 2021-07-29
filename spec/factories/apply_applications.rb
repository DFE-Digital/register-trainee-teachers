# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { ApiStubs::ApplyApi.application }
    invalid_data { {} }
    provider

    trait :with_invalid_data do
      invalid_data { { "degrees" => { "BUpwce1Qe9RDM3A9AmgsmaNT" => { "subject" => "Master's Degree" } } } }
    end
  end
end
