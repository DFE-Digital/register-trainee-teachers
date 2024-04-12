# frozen_string_literal: true

module DegreeSerializer
  class V01
    EXCLUDE_ATTRIBUTES = %w[
      id
      slug
      trainee_id
      dttp_id
    ].freeze

    def initialize(degree)
      @degree = degree
    end

    def as_hash
      @degree.attributes.except(*EXCLUDE_ATTRIBUTES).merge({
        subject:,
        institution:,
        country:,
        degree_type:,
        grade:,
      })
    end

    def subject
      @degree.subject_one
    end

    def institution
      DfEReference::DegreesQuery.find_institution(name: @degree.institution)[:hesa_itt_code]
    end

    def country
      Hesa::CodeSets::Countries::MAPPING.key(@degree.country)
    end

    def degree_type
      types = DfE::ReferenceData::Degrees::TYPES.all_as_hash
      matching_type = types.find { |_, item| item[:name] == @degree.degree_type }
      matching_type[:hesa_itt_code]
    end

    def grade
      grades = DfE::ReferenceData::Degrees::GRADES.all_as_hash
      matching_grade = grades.find { |_, item| item[:name] == @degree.grade }
      matching_grade[:hesa_code]
    end
  end
end
