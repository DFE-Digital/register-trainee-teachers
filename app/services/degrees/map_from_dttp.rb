# frozen_string_literal: true

module Degrees
  class MapFromDttp
    include ServicePattern

    def initialize(dttp_degree:)
      @dttp_degree = dttp_degree
    end

    def call
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
        uk_degree: qualification_type,
        institution: institution || inactive_institution,
        grade: grade.presence || Dttp::CodeSets::Grades::OTHER,
        # Maybe?
        # other_grade: dttp_degree.response["dfe_name"]
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
      country && country != Dttp::CodeSets::Countries::UNITED_KINGDOM
    end

    def non_uk_degree
      # For non-uk degrees, dfe_name has more detail than dfe_degreetypeid_value
      dttp_degree.response["dfe_name"] || qualification_type
    end

    def subject
      find_by_entity_id(
        dttp_degree.response["_dfe_degreesubjectid_value"],
        Dttp::CodeSets::DegreeSubjects::MAPPING,
      )
    end

    def qualification_type
      find_by_entity_id(
        dttp_degree.response["_dfe_degreetypeid_value"],
        Dttp::CodeSets::DegreeTypes::MAPPING,
      )
    end

    def institution
      find_by_entity_id(dttp_degree.institution, Dttp::CodeSets::Institutions::MAPPING)
    end

    def inactive_institution
      find_by_entity_id(dttp_degree.institution, Dttp::CodeSets::Institutions::INACTIVE_MAPPING)
    end

    def grade
      find_by_entity_id(
        dttp_degree.response["_dfe_classofdegreeid_value"],
        Dttp::CodeSets::Grades::MAPPING,
      )
    end

    def country
      @country ||= find_by_entity_id(
        dttp_degree.country_id,
        Dttp::CodeSets::Countries::MAPPING,
      )
    end

    def find_by_entity_id(id, mapping)
      mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
    end
  end
end
