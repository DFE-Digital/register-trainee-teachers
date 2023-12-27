# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { JSON.parse(ApiStubs::RecruitsApi.application(degree_attributes:)) }
    invalid_data { {} }
    accredited_body_code { create(:provider).code }
    recruitment_cycle_year { Settings.apply_applications.create.recruitment_cycle_year }

    transient do
      degree_slug { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s }
      invalid_institution { "Unknown institution" }
      invalid_subject { "History1" }
      degree_attributes { {} }
    end

    trait :invalid do
      degree_attributes { { institution_details: invalid_institution } }
    end

    trait :importable do
      state { "importable" }
    end

    trait :importable do
      state { "importable" }
    end

    trait :non_importable_duplicate do
      state { "non_importable_duplicate" }
    end

    trait :with_invalid_data do
      invalid
      invalid_data do
        {
          "degrees" => {
            degree_slug => {
              institution: invalid_institution,
            },
          },
        }
      end
    end

    trait :with_multiple_invalid_data do
      invalid_data do
        { "degrees" => {
          degree_slug => {
            institution: invalid_institution,
            subject: invalid_subject,
          },
        } }
      end
    end
  end
end
