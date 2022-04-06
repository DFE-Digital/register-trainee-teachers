# frozen_string_literal: true

module Degrees
  class MapFromDttp
    include ServicePattern
    include HasDttpMapping

    BURSARY_RELATED = 1

    def initialize(dttp_degree:, dttp_trainee:)
      @dttp_degree = dttp_degree
      @dttp_trainee = dttp_trainee
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

    attr_reader :dttp_degree, :dttp_trainee

    def degree_params
      non_uk_degree? ? non_uk_degree_params : uk_degree_params
    end

    def common_params
      {
        subject: subject,
        graduation_year: dttp_degree.end_year || undergrad_date,
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

    def non_uk_degree
      # For non-uk degrees, dfe_name has more detail than dfe_degreetypeid_value
      dttp_degree.response["dfe_name"] || degree_type
    end

    def subject
      find_by_entity_id(dttp_degree.subject, Dttp::CodeSets::DegreeSubjects::MAPPING) ||
        Dttp::CodeSets::JacsSubjects::MAPPING[dttp_degree.subject]
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

    # Only the date for the bursary-related degree is saved onto the placement assignment
    def undergrad_date
      return unless degree_is_bursary_related?

      dttp_trainee.latest_placement_assignment.response["dfe_undergraddegreedateobtained"]
    end

    def degree_is_bursary_related?
      dttp_degree.response["dfe_bursaryflag"] == BURSARY_RELATED
    end
  end
end
