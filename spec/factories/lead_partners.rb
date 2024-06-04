# frozen_string_literal: true

FactoryBot.define do
  factory :lead_partner do
    urn { Faker::Number.unique.number(digits: 6) }

    trait :lead_school do
      record_type { LeadPartner::LEAD_SCHOOL }
      school
    end

    trait :hei do
      record_type { LeadPartner::HEI }
      provider
      ukprn { Faker::Number.number(digits: 8) }
    end
  end
end
