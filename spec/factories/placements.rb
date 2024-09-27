# frozen_string_literal: true

FactoryBot.define do
  factory :placement do
    trainee
    slug { Faker::Alphanumeric.alphanumeric(number: Sluggable::SLUG_LENGTH) }

    name { Faker::University.name }
    address { Faker::Address.street_address }
    postcode { Faker::Address.postcode }

    school { nil }
    urn { nil }

    trait :with_school do
      school

      after(:build) do |placement, evaluator|
        placement.urn      = evaluator.school&.urn
        placement.name     = evaluator.school&.name
        placement.postcode = evaluator.school&.postcode
      end
    end

    trait :not_applicable_school do
      school { nil }
      urn { Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.sample }
      name { I18n.t("components.placement_detail.magic_urn.#{urn}") }
      address { nil }
      postcode { nil }
    end
  end
end
