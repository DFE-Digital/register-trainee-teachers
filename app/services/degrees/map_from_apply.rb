# frozen_string_literal: true

module Degrees
  class MapFromApply
    include ServicePattern

    UK_DEGREE_CODES = %w[UK XK].freeze

    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      common_params.merge(degree_params)
    end

  private

    attr_reader :attributes

    def degree_params
      uk_degree? ? uk_degree_params : non_uk_degree_params
    end

    def common_params
      {
        is_apply_import: true,
        graduation_year: attributes["award_year"],
      }.merge(subject_params)
    end

    def uk_degree_params
      {
        locale_code: Trainee.locale_codes[:uk],
      }.merge(qualification_type_params)
       .merge(grade_params)
       .merge(institution_params)
    end

    def non_uk_degree_params
      {
        locale_code: Trainee.locale_codes[:non_uk],
        non_uk_degree: attributes["comparable_uk_degree"],
        country: country,
      }
    end

    def qualification_type_params
      qualification_type = find_dfe_reference_type

      if qualification_type
        { uk_degree: qualification_type.name, uk_degree_uuid: qualification_type.id }
      else
        { uk_degree: attributes["qualification_type"] }
      end
    end

    def institution_params
      institution = find_dfe_reference_institution

      if institution
        { institution: institution.name, institution_uuid: institution.id }
      else
        { institution: attributes["institution_details"] }
      end
    end

    def subject_params
      subject = find_dfe_reference_subject

      if subject
        { subject: subject.name, subject_uuid: subject.id }
      else
        { subject: attributes["subject"] }
      end
    end

    def grade_params
      grade = find_dfe_reference_grade

      if grade
        { grade: grade.name, grade_uuid: grade.id, other_grade: nil }
      else
        { grade: Degrees::DfEReference::OTHER, grade_uuid: nil, other_grade: attributes["grade"] }
      end
    end

    def uk_degree?
      if attributes["hesa_degctry"]
        UK_DEGREE_CODES.include?(attributes["hesa_degctry"])
      else
        attributes["comparable_uk_degree"].nil? && attributes["non_uk_qualification_type"].nil?
      end
    end

    def find_dfe_reference_subject
      DfEReference.find_subject(uuid: attributes["subject_uuid"],
                                name: attributes["subject"],
                                hecos_code: attributes["hesa_degsbj"])
    end

    def find_dfe_reference_type
      DfEReference.find_type(uuid: attributes["degree_type_uuid"],
                             abbreviation: attributes["qualification_type"],
                             hesa_code: attributes["hesa_degtype"])
    end

    def find_dfe_reference_institution
      DfEReference.find_institution(uuid: attributes["institution_uuid"],
                                    name: attributes["institution_details"].split(",").first,
                                    hesa_code: attributes["hesa_degest"])
    end

    def find_dfe_reference_grade
      DfEReference.find_grade(uuid: attributes["grade_uuid"],
                              name: attributes["grade"],
                              hesa_code: attributes["hesa_degclss"])
    end

    def country
      Dttp::CodeSets::Countries::MAPPING.find { |_, v| v[:country_code] == attributes["hesa_degctry"] }&.first
    end
  end
end
