# frozen_string_literal: true

FactoryBot.define do
  factory :funding_school_designation do
    school
    academic_cycle { AcademicCycle.current || create(:academic_cycle, :current) }
    designation { "disadvantaged" }

    trait :special do
      designation { "special" }
    end
  end
end
