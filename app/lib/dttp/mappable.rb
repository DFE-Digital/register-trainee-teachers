# frozen_string_literal: true

module Dttp
  module Mappable
    def course_subject_id(subject)
      CodeSets::CourseSubjects::MAPPING.dig(subject, :entity_id)
    end

    def course_phase_id(age_range)
      CodeSets::AgeRanges::MAPPING.dig(age_range, :entity_id)
    end

    def course_study_mode_id(study_mode)
      CodeSets::CourseStudyModes::MAPPING.dig(study_mode, :entity_id)
    end

    def degree_subject_id(subject)
      CodeSets::DegreeSubjects::MAPPING.dig(subject, :entity_id)
    end

    def degree_institution_id(institution)
      CodeSets::Institutions::MAPPING.dig(institution, :entity_id)
    end

    def degree_class_id(grade)
      CodeSets::Grades::MAPPING.dig(grade, :entity_id)
    end

    def degree_country_id(country)
      CodeSets::Countries::MAPPING.dig(country, :entity_id)
    end

    def degree_type_id(degree_type)
      CodeSets::DegreeTypes::MAPPING.dig(degree_type, :entity_id)
    end

    def dttp_nationality_id(nationality)
      CodeSets::Nationalities::MAPPING.dig(nationality.downcase, :entity_id)
    end

    def dttp_route_id(training_route)
      CodeSets::Routes::MAPPING.dig(training_route, :entity_id)
    end

    def dttp_disability_id(disability)
      CodeSets::Disabilities::MAPPING.dig(disability, :entity_id)
    end

    def dttp_ethnicity_id(ethnicity)
      CodeSets::Ethnicities::MAPPING.dig(ethnicity, :entity_id)
    end

    def dttp_status_id(status)
      CodeSets::Statuses::MAPPING.dig(status, :entity_id)
    end

    def dttp_reason_for_leaving_id(reason)
      CodeSets::ReasonsForLeavingCourse::MAPPING.dig(reason, :entity_id)
    end

    def dttp_qualification_aim_id(training_route)
      CodeSets::QualificationAims::MAPPING.dig(training_route, :entity_id)
    end

    def dttp_school_id(urn)
      Dttp::School.find_by(urn: urn)&.dttp_id
    end

    def training_initiative_id(training_initiative)
      CodeSets::TrainingInitiatives::MAPPING.dig(training_initiative, :entity_id)
    end
  end
end
