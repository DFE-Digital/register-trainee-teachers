# frozen_string_literal: true

module Degrees
  class CreateFromDttpPlacementAssignment
    include ServicePattern
    include HasDttpMapping

    def initialize(trainee:)
      @trainee = trainee
      @dttp_trainee = trainee.dttp_trainee
      @placement_assignment = trainee.dttp_trainee.latest_placement_assignment
    end

    def call
      return if dttp_trainee.degree_qualifications.present? || trainee.degrees.present?

      create_degree_from_placement_assignment!
    end

  private

    attr_reader :placement_assignment, :dttp_trainee, :trainee

    def create_degree_from_placement_assignment!
      attrs = common_params.merge(degree_params)

      trainee.degrees.create!(attrs)
    end

    def common_params
      {
        subject: subject,
        graduation_year: placement_assignment.degree_year,
        institution: institution,
        grade: grade || Dttp::CodeSets::Grades::OTHER,
      }
    end

    def degree_params
      non_uk_degree? ? non_uk_degree_params : uk_degree_params
    end

    def uk_degree_params
      {
        locale_code: Degree.locale_codes[:uk],
        uk_degree: degree_type,
      }
    end

    def non_uk_degree_params
      {
        locale_code: Degree.locale_codes[:non_uk],
        non_uk_degree: degree_type,
        country: country,
      }
    end

    def subject
      find_by_entity_id(placement_assignment.degree_subject, Dttp::CodeSets::DegreeSubjects::MAPPING) ||
        Dttp::CodeSets::JacsSubjects::MAPPING[placement_assignment.degree_subject]
    end

    def institution
      find_by_entity_id(placement_assignment.degree_awarding_institution, Dttp::CodeSets::Institutions::MAPPING) ||
        Dttp::CodeSets::Institutions::INACTIVE_MAPPING[placement_assignment.degree_awarding_institution] ||
        Dttp::Account.find_by(dttp_id: placement_assignment.degree_awarding_institution)&.response&.fetch("name")
    end

    def grade
      find_by_entity_id(placement_assignment.degree_grade, Dttp::CodeSets::Grades::MAPPING)
    end

    def degree_type
      find_by_entity_id(placement_assignment.degree_type, Dttp::CodeSets::DegreeTypes::MAPPING) ||
        find_by_entity_id(placement_assignment.degree_type, Dttp::CodeSets::DegreeTypes::INACTIVE_MAPPING) ||
          find_by_entity_id(placement_assignment.degree_type, Dttp::CodeSets::DegreeOrEquivalentQualifications::MAPPING)
    end

    def country
      find_by_entity_id(placement_assignment.degree_country, Dttp::CodeSets::Countries::MAPPING) ||
        find_by_entity_id(placement_assignment.degree_country, Dttp::CodeSets::Countries::INACTIVE_MAPPING)
    end
  end
end
