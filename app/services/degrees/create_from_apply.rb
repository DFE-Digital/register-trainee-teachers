# frozen_string_literal: true

module Degrees
  class CreateFromApply
    include ServicePattern

    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      degree
    end

  private

    attr_reader :attributes

    def degree
      Degree.new(params)
    end

    def params
      @params ||= uk_degree? ? uk_degree_params : non_uk_degree_params
    end

    # TODO: Check that each of degree, subject and institution is in our
    # Dttp codeset mappings before saving.
    def uk_degree_params
      {
        locale_code: 0,
        uk_degree: attributes["qualification_type"],
        subject: attributes["subject"],
        institution: institution,
        graduation_year: attributes["award_year"],
        grade: attributes["grade"],
      }
    end

    def non_uk_degree_params
      {
        locale_code: 1,
        # TODO: This should be the comparable_uk_degree` from Apply
        non_uk_degree: attributes["non_uk_qualification_type"],
        subject: attributes["subject"],
        graduation_year: attributes["award_year"],
        country: country(attributes["hesa_degctry"]),
      }
    end

    def uk_degree?
      attributes["non_uk_qualification_type"].nil?
    end

    def institution
      attributes["institution_details"].split(",").first
    end

    # TODO: Check that it's not null
    def country(code)
      Dttp::CodeSets::Countries::MAPPING.find { |_, v| v[:country_code] == code }.first
    end
  end
end
