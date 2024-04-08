# frozen_string_literal: true

module DegreeSerializer
  class V01
    def initialize(degree)
      @degree = degree
    end

    def as_hash
      @degree.attributes
    end

    def subject_one
      @degree.subject_one
    end

    def institution
      DfEReference::DegreesQuery.find_institution(name: @degree.institution)
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
