# frozen_string_literal: true

FactoryBot.define do
  factory :funding_method do
    training_route { ReferenceData::TRAINING_ROUTES.names.sample }
    amount { Faker::Number.number(digits: 5) }
    funding_type { FUNDING_TYPE_ENUMS[:bursary] }
    academic_cycle { AcademicCycle.current || create(:academic_cycle, :current) }

    trait :with_subjects do
      after(:create) do |funding_method, _|
        create_list(:funding_method_subject, 2, funding_method:)
      end
    end
  end
end
