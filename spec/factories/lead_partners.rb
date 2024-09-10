# frozen_string_literal: true

FactoryBot.define do
  factory :lead_partner do
    name { school&.name || provider&.name }
    urn { Faker::Number.unique.number(digits: 6) }

    trait :school do
      record_type { LeadPartner::SCHOOL }
      school

      before(:create) do |record|
        record.urn = record.school.urn
      end
    end

    trait :hei do
      record_type { LeadPartner::HEI }
      provider factory: %i[provider unaccredited]
      ukprn { Faker::Number.number(digits: 8) }
    end

    trait :scitt do
      record_type { LeadPartner::SCITT }
      provider factory: %i[provider unaccredited]
      ukprn { Faker::Number.number(digits: 8) }
    end

    trait :discarded do
      discarded_at { Time.zone.now }
    end
  end
end
