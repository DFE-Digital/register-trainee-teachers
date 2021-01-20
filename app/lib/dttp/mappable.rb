# frozen_string_literal: true

module Dttp
  module Mappable
    def programme_subject_id(subject)
      Dttp::CodeSets::ProgrammeSubjects::MAPPING.dig(subject, :entity_id)
    end

    def course_phase_id(age_range)
      Dttp::CodeSets::AgeRanges::MAPPING.dig(age_range, :entity_id)
    end

    def degree_subject_id(subject)
      Dttp::CodeSets::DegreeSubjects::MAPPING.dig(subject, :entity_id)
    end

    def degree_institution_id(institution)
      Dttp::CodeSets::Institutions::MAPPING.dig(institution, :entity_id)
    end

    def degree_class_id(grade)
      Dttp::CodeSets::Grades::MAPPING.dig(grade, :entity_id)
    end

    def degree_country_id(country)
      Dttp::CodeSets::Countries::MAPPING.dig(country, :entity_id)
    end

    def degree_type_id(degree_type)
      Dttp::CodeSets::DegreeTypes::MAPPING.dig(degree_type, :entity_id)
    end

    def dttp_disability_id(disability)
      CodeSets::Disabilities::MAPPING.dig(disability, :entity_id)
    end

    def dttp_ethnicity_id(ethnicity)
      CodeSets::Ethnicities::MAPPING.dig(ethnicity, :entity_id)
    end
  end
end
