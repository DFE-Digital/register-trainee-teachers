# frozen_string_literal: true

FactoryBot.define do
  factory :placement do
    trainee
    slug { Faker::Alphanumeric.alphanumeric(number: Sluggable::SLUG_LENGTH) }

    urn { Faker::Number.unique.number(digits: 6).to_s }
    name { Faker::University.name }
    address { nil }
    postcode { Faker::Address.postcode }

    school { nil }

    trait :with_school do
      school

      urn { nil }
      name { nil }
      address { nil }
      postcode { nil }
    end

    trait :not_applicable_school do
      school { nil }
      urn { School::NOT_APPLICABLE_SCHOOL_URNS.sample }
      name { I18n.t("components.placement_detail.magic_urn.#{urn}") }
      address { nil }
      postcode { nil }
    end
  end
end
