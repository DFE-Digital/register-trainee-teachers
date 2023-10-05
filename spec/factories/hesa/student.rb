# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_student, class: "Hesa::Student" do
    ukprn { Faker::Number.number(digits: 8) }
    bursary_level { Hesa::CodeSets::BursaryLevels::VALUES.keys.sample }
    collection_reference { Settings.hesa.current_collection_reference }
  end
end
