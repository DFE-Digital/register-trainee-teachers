# frozen_string_literal: true

module DegreeSerializer
  class V01
    EXCLUDED_ATTRIBUTES = %w[
      id
      slug
      trainee_id
      dttp_id
      locale_code
    ].freeze

    def initialize(degree)
      @degree = degree
    end

    def as_hash
      @degree.attributes.except(*EXCLUDED_ATTRIBUTES).merge({
        subject:,
        institution:,
        country:,
        degree_type:,
        grade:,
      })
    end

    def subject
      @degree.subject
    end

    def institution
      institutions =  DfEReference::DegreesQuery::INSTITUTIONS.constituent_lists.first.all_as_hash
      institution = institutions.find { |_, item| item[:name] == @degree.institution }.last
      return if institution.blank?

      institution[:hesa_itt_code]
    end

    def country
      Hesa::CodeSets::Countries::MAPPING.key(@degree.country)
    end

    def degree_type
      types = DfE::ReferenceData::Degrees::TYPES.all_as_hash
      matching_type = types.find { |_, item| item[:name] == (@degree.uk_degree || @degree.non_uk_degree) }&.last
      return if matching_type.blank?

      matching_type[:hesa_itt_code]
    end

    def grade
      grades = DfE::ReferenceData::Degrees::GRADES.all_as_hash
      matching_grade = grades.find { |_, item| item[:name] == @degree.grade }&.last
      return if matching_grade.blank?

      matching_grade[:hesa_code]
    end
  end
end
