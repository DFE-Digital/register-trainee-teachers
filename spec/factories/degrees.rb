# frozen_string_literal: true

FactoryBot.define do
  factory :degree, class: "Degree" do
    trainee

    uk_degree_type

    slug { Faker::Alphanumeric.alphanumeric(number: Sluggable::SLUG_LENGTH) }

    trait :uk_degree_type do
      locale_code { :uk }
      uk_degree { uk_degree_uuid && DfEReference::DegreesQuery::TYPES.one(uk_degree_uuid).name }
      uk_degree_uuid do
        DfEReference::DegreesQuery::TYPES.all.reject { |type| type[:name].include?("Foundation") }.sample.id
      end
    end

    trait :uk_degree_with_details do
      uk_degree_type

      subject_uuid { DfEReference::DegreesQuery::SUBJECTS.all.sample.id }
      grade_uuid { DfEReference::DegreesQuery::SUPPORTED_GRADES_WITH_OTHER.all.sample.id }
      institution_uuid { DfE::ReferenceData::Degrees::INSTITUTIONS.all.sample.id }

      subject { subject_uuid && DfEReference::DegreesQuery::SUBJECTS.one(subject_uuid).name }
      grade { grade_uuid && DfEReference::DegreesQuery::SUPPORTED_GRADES_WITH_OTHER.one(grade_uuid).name }
      institution { institution_uuid && DfE::ReferenceData::Degrees::INSTITUTIONS.one(institution_uuid).name }

      graduation_year { rand((Time.zone.now.year.next - Degree::MAX_GRAD_YEARS)..Time.zone.now.year.next) }
    end

    trait :non_uk_degree_type do
      locale_code { :non_uk }
      uk_degree { nil }
      non_uk_degree { ENIC_NON_UK.sample }
      uk_degree_uuid { nil }
    end

    trait :non_uk_degree_with_details do
      non_uk_degree_type
      subject { DfEReference::DegreesQuery::SUBJECTS.all.sample.name }
      grade { DfEReference::DegreesQuery::SUPPORTED_GRADES_WITH_OTHER.all.sample.name }
      country { CodeSets::Countries::MAPPING.keys.sample }
      graduation_year { rand((Time.zone.now.year.next - Degree::MAX_GRAD_YEARS)..Time.zone.now.year.next) }
    end

    trait :uk_foundation do
      transient do
        degree_type { DfEReference::DegreesQuery::TYPES.all.select { |type| type[:name].include?("Foundation") }.sample }
      end

      locale_code { :uk }
      uk_degree { degree_type.name }
      uk_degree_uuid { degree_type.id }
    end
  end
end
