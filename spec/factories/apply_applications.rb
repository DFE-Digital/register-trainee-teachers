# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { JSON.parse(ApiStubs::ApplyApi.application) }
    invalid_data { {} }
    accredited_body_code { create(:provider).code }
    recruitment_cycle_year { Settings.apply_applications.create.recruitment_cycle_year }

    trait :importable do
      state { "importable" }
    end

    trait :imported do
      state { "imported" }
    end

    trait :with_invalid_data do
      invalid_data do
        {
          "degrees" => {
            SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s => {
              institution: "University of Warwick",
            },
          },
        }
      end
    end

    trait :with_multiple_invalid_data do
      invalid_data do
        { "degrees" => {
          SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s => {
            institution: "University of Warwick",
            subject: "History1",
          },
        } }
      end
    end
  end
end
