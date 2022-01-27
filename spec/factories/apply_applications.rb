# frozen_string_literal: true

FactoryBot.define do
  factory :apply_application do
    sequence(:apply_id)
    application { JSON.parse(ApiStubs::ApplyApi.application) }
    invalid_data { {} }
    accredited_body_code { create(:provider).code }
    recruitment_cycle_year { Settings.apply_applications.create.recruitment_cycle_year }

    transient do
      degree_slug { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s }
      invalid_institution { "University of Warwick" }
      invalid_subject { "History1" }
    end

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
