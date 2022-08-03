# frozen_string_literal: true

NEXT_YEAR = Time.zone.now.year.next unless defined?(NEXT_YEAR)

FactoryBot.define do
  factory :degree, class: "Degree" do
    association :trainee

    uk_degree_type

    slug { SecureRandom.base58(Sluggable::SLUG_LENGTH) }

    trait :uk_degree_type do
      locale_code { :uk }
      uk_degree { uk_degree_uuid && Degrees::DfeReference::TYPES.one(uk_degree_uuid).name }
      uk_degree_uuid { Degrees::DfeReference::TYPES.all.sample.id }
    end

    trait :uk_degree_with_details do
      uk_degree_type

      subject_uuid { Degrees::DfeReference::SUBJECTS.all.sample.id }
      grade_uuid { Degrees::DfeReference::GRADES.all.sample.id }
      institution_uuid { DfE::ReferenceData::Degrees::INSTITUTIONS.all.sample.id }

      subject { subject_uuid && Degrees::DfeReference::SUBJECTS.one(subject_uuid).name }
      grade { grade_uuid && Degrees::DfeReference::GRADES.one(grade_uuid).name }
      institution { institution_uuid && DfE::ReferenceData::Degrees::INSTITUTIONS.one(institution_uuid).name }

      graduation_year { rand(NEXT_YEAR - Degree::MAX_GRAD_YEARS..NEXT_YEAR) }
    end

    trait :non_uk_degree_type do
      locale_code { :non_uk }
      uk_degree { nil }
      non_uk_degree { ENIC_NON_UK.sample }
    end

    trait :non_uk_degree_with_details do
      non_uk_degree_type
      subject { Degrees::DfeReference::SUBJECTS.all.sample.name }
      grade { Degrees::DfeReference::GRADES.all.sample.name }
      country { Dttp::CodeSets::Countries::MAPPING.keys.sample }
      graduation_year { rand(NEXT_YEAR - Degree::MAX_GRAD_YEARS..NEXT_YEAR) }
    end
  end
end
