# frozen_string_literal: true

NEXT_YEAR = Time.zone.now.year.next unless defined?(NEXT_YEAR)

FactoryBot.define do
  factory :degree, class: Degree do
    association :trainee

    uk_degree_type

    slug { SecureRandom.base58(Sluggable::SLUG_LENGTH) }

    trait :uk_degree_type do
      locale_code { :uk }
      uk_degree { (Dttp::CodeSets::DegreeTypes::MAPPING.keys - Dttp::CodeSets::DegreeTypes::NON_UK).sample }
    end

    trait :uk_degree_with_details do
      uk_degree_type

      subject { Dttp::CodeSets::DegreeSubjects::MAPPING.keys.sample }

      institution { Dttp::CodeSets::Institutions::MAPPING.keys.sample }
      grade { Dttp::CodeSets::Grades::MAPPING.keys.sample }
      graduation_year { rand(NEXT_YEAR - Degree::MAX_GRAD_YEARS..NEXT_YEAR) }
    end

    trait :non_uk_degree_type do
      locale_code { :non_uk }
      uk_degree { nil }
      non_uk_degree { ENIC_NON_UK.sample }
    end

    trait :non_uk_degree_with_details do
      non_uk_degree_type

      subject { Dttp::CodeSets::DegreeSubjects::MAPPING.keys.sample }

      grade { Dttp::CodeSets::Grades::MAPPING.keys.sample }
      country { Dttp::CodeSets::Countries::MAPPING.keys.sample }
      graduation_year { rand(NEXT_YEAR - Degree::MAX_GRAD_YEARS..NEXT_YEAR) }
    end
  end
end
