# frozen_string_literal: true

FactoryBot.define do
  factory :lead_partner do
    name { school&.name || provider&.name }
    urn { Faker::Number.unique.number(digits: 6) }

    trait :lead_school do
      record_type { LeadPartner::LEAD_SCHOOL }
      school
    end

    trait :hei do
      record_type { LeadPartner::HEI }
      provider factory: %i[provider unacreddited]
      ukprn { Faker::Number.number(digits: 8) }
    end

    trait :scitt do
      record_type { LeadPartner::SCITT }
      provider factory: %i[provider unacreddited]
      ukprn { Faker::Number.number(digits: 8) }
    end
  end
end
