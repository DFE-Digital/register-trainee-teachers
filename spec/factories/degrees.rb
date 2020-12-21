# frozen_string_literal: true

FactoryBot.define do
  factory :degree, class: Degree do
    association :trainee

    uk_degree_type

    subject { Dttp::CodeSets::DegreeSubjects::MAPPING.keys.sample }
    graduation_year { Time.zone.today.year - rand(9) }

    trait :uk_degree_type do
      locale_code { :uk }
      uk_degree { HESA_DEGREE_TYPES.sample[2] }
    end

    trait :uk_degree_with_details do
      uk_degree_type
      institution { Dttp::CodeSets::Institutions::MAPPING.keys.sample }
      grade { Dttp::CodeSets::Grades::MAPPING.keys.sample }
    end

    trait :non_uk_degree_type do
      locale_code { :non_uk }
      uk_degree { nil }
      non_uk_degree { NARIC_NON_UK.sample }
    end

    trait :non_uk_degree_with_details do
      non_uk_degree_type
      country { Dttp::CodeSets::Countries::MAPPING.keys.sample }
    end
  end
end
