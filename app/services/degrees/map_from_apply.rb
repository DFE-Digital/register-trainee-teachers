# frozen_string_literal: true

module Degrees
  class MapFromApply
    include ServicePattern
    include MappingsHelper

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
        subject: subject,
        graduation_year: attributes["award_year"],
      }
    end

    def uk_degree_params
      {
        locale_code: Trainee.locale_codes[:uk],
        uk_degree: qualification_type,
        institution: institution,
        grade: grade.presence || Dttp::CodeSets::Grades::OTHER,
        other_grade: grade.present? ? nil : attributes["grade"],
      }
    end

    def non_uk_degree_params
      {
        locale_code: Trainee.locale_codes[:non_uk],
        non_uk_degree: attributes["comparable_uk_degree"],
        country: country,
      }
    end

    def uk_degree?
      attributes["non_uk_qualification_type"].nil?
    end

    def subject
      course_subject = Dttp::CodeSets::DegreeSubjects::MAPPING.find do |k, _|
        same_string?(k, attributes["subject"])
      end

      course_subject.presence&.first || attributes["subject"]
    end

    def qualification_type
      degree_type = Dttp::CodeSets::DegreeTypes::MAPPING.find do |k, v|
        same_hesa_code?(v[:hesa_code], attributes["hesa_degtype"]) ||
        same_string?(v[:abbreviation], attributes["qualification_type"]) ||
        same_string?(k, attributes["qualification_type"])
      end

      degree_type.presence&.first || attributes["qualification_type"]
    end

    def institution
      institution_details = attributes["institution_details"].split(",").first

      institution_type = Dttp::CodeSets::Institutions::MAPPING.find do |k, v|
        same_hesa_code?(v[:hesa_code], attributes["hesa_degest"]) ||
        same_string?(k, institution_details)
      end

      institution_type.presence&.first || institution_details
    end

    def grade
      @grade ||= Dttp::CodeSets::Grades::MAPPING.find do |key, value|
        same_hesa_code?(value[:hesa_code], attributes["hesa_degclss"]) || almost_identical?(key, attributes["grade"])
      end&.first
    end

    def country
      Dttp::CodeSets::Countries::MAPPING.find { |_, v| v[:country_code] == attributes["hesa_degctry"] }.first
    end
  end
end
