# frozen_string_literal: true

module Degrees
  class MapFromDttp
    include ServicePattern
    include HasDttpMapping

    def initialize(dttp_degree:)
      @dttp_degree = dttp_degree
    end

    def call
      if unmapped_subject?
        dttp_degree.non_importable_missing_subject!
        return
      end

      if unmapped_degree_type?
        dttp_degree.non_importable_missing_type!
        return
      end

      if unmapped_institution?
        dttp_degree.non_importable_missing_institution!
        return
      end

      if unmapped_country?
        dttp_degree.non_importable_missing_country!
        return
      end

      common_params.merge(degree_params)
    end

  private

    attr_reader :dttp_degree

    def degree_params
      non_uk_degree? ? non_uk_degree_params : uk_degree_params
    end

    def common_params
      {
        subject: subject,
        graduation_year: dttp_degree.end_year,
      }
    end

    def uk_degree_params
      {
        locale_code: Trainee.locale_codes[:uk],
        uk_degree: degree_type,
        institution: institution,
        grade: grade.presence || Dttp::CodeSets::Grades::OTHER,
      }
    end

    def non_uk_degree_params
      {
        locale_code: Trainee.locale_codes[:non_uk],
        non_uk_degree: non_uk_degree,
        country: country,
      }
    end

    def non_uk_degree?
      country && united_kingdom_countries.exclude?(country)
    end

    def united_kingdom_countries
      [
        Dttp::CodeSets::Countries::UNITED_KINGDOM,
        Dttp::CodeSets::Countries::ENGLAND,
        Dttp::CodeSets::Countries::NORTHERN_IRELAND,
        Dttp::CodeSets::Countries::SCOTLAND,
        Dttp::CodeSets::Countries::UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED,
        Dttp::CodeSets::Countries::WALES,
      ]
    end

    def non_uk_degree
      # For non-uk degrees, dfe_name has more detail than dfe_degreetypeid_value
      dttp_degree.response["dfe_name"] || degree_type
    end

    def subject
      find_by_entity_id(dttp_degree.subject, Dttp::CodeSets::DegreeSubjects::MAPPING)
    end

    def unmapped_subject?
      dttp_degree.subject.present? && subject.blank?
    end

    def degree_type
      find_by_entity_id(dttp_degree.degree_type, Dttp::CodeSets::DegreeTypes::MAPPING) ||
        find_by_entity_id(dttp_degree.degree_type, Dttp::CodeSets::DegreeTypes::INACTIVE_MAPPING)
    end

    def unmapped_degree_type?
      dttp_degree.degree_type.present? && degree_type.blank?
    end

    def institution
      find_by_entity_id(dttp_degree.institution, Dttp::CodeSets::Institutions::MAPPING) ||
        find_by_entity_id(dttp_degree.institution, Dttp::CodeSets::Institutions::INACTIVE_MAPPING)
    end

    def unmapped_institution?
      dttp_degree.institution.present? && institution.blank?
    end

    def grade
      find_by_entity_id(dttp_degree.grade, Dttp::CodeSets::Grades::MAPPING)
    end

    def country
      find_by_entity_id(dttp_degree.country, Dttp::CodeSets::Countries::MAPPING) ||
        find_by_entity_id(dttp_degree.country, Dttp::CodeSets::Countries::INACTIVE_MAPPING)
    end

    def unmapped_country?
      dttp_degree.country.present? && country.blank?
    end
  end
end
