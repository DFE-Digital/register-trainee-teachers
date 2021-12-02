# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
    end

    def call
      return if provider.blank?
      return if placement_assignment.blank?

      if trainee_already_exists?
        dttp_trainee.non_importable_duplicate!
        return
      end

      trainee = Trainee.new(mapped_attributes)

      trainee.save!

      dttp_trainee.imported!

      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      {
        provider: provider,
        first_names: dttp_trainee.response["firstname"],
        last_name: dttp_trainee.response["lastname"],
        address_line_one: dttp_trainee.response["address1_line1"],
        address_line_two: dttp_trainee.response["address1_line2"],
        town_city: dttp_trainee.response["address1_line3"],
        postcode: dttp_trainee.response["address1_postalcode"],
        date_of_birth: dttp_trainee.date_of_birth,
        email: dttp_trainee.response["emailaddress1"],
        gender: trainee_gender,
        trainee_id: trainee_id,
        nationalities: nationalities,
        training_route: training_route,
        trn: dttp_trainee.response["dfe_trn"],
        dttp_id: dttp_trainee.dttp_id,
      }.merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
    end

    def provider
      @provider ||= Provider.find_by(dttp_id: dttp_trainee.provider_dttp_id)
    end

    def placement_assignment
      @placement_assignment ||= dttp_trainee.placement_assignments.first
    end

    def trainee_already_exists?
      Trainee.exists?(dttp_id: dttp_trainee.dttp_id)
    end

    def training_route
      find_by_entity_id(placement_assignment.route_dttp_id, Dttp::CodeSets::Routes::MAPPING)
    end

    def trainee_gender
      # TODO: Need to take a decision on mapping gender other/not provided
      # Hash#invert might not be desirable as we lose one of the duplicated values
      Dttp::Params::Contact::GENDER_CODES.invert[dttp_trainee.response["gendercode"].to_i]
    end

    def trainee_id
      return if dttp_trainee.response["dfe_traineeid"] == Dttp::Params::Contact::NOT_PROVIDED

      dttp_trainee.response["dfe_traineeid"]
    end

    def nationalities
      # TODO: We have a few different names for british and some other citizenships
      # ["american", "british", "cook islander", "cymraes", "cymro", "french", "israeli", "martiniquais", "mosotho", "new zealander", "puerto rican", "st helenian", "turkish"]
      Nationality.where(name: nationality_names)
    end

    def nationality_names
      [
        find_by_entity_id(dttp_trainee.response["_dfe_nationality_value"], Dttp::CodeSets::Nationalities::MAPPING),
      ]
    end

    def disability_attributes
      if disability.blank?
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
        }
      end

      if disability == Diversities::NO_KNOWN_DISABILITY
        return {
          diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
        }
      end

      # TODO: This needs a decision, since DTTP may have 'multiple disabilities'
      if disability == Diversities::MULTIPLE_DISABILITIES
        return {
          diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
          disabilities: Disability.where(name: ::Diversities::OTHER),
        }
      end

      {
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        disabilities: Disability.where(name: disability),
      }
    end

    def disability
      @disability ||= find_by_entity_id(dttp_trainee.response["_dfe_disibilityid_value"], Dttp::CodeSets::Disabilities::MAPPING)
    end

    def ethnicity_attributes
      ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

      diversity_disclosure = ethnic_background.present? && ethnic_background != Diversities::NOT_PROVIDED

      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        return {
          ethnic_background: ethnic_background,
          ethnic_group: ethnic_group,
          diversity_disclosure: diversity_disclosure,
        }
      end

      {}
    end

    def ethnic_background
      @ethnic_background ||= find_by_entity_id(dttp_trainee.response["_dfe_ethnicityid_value"], Dttp::CodeSets::Ethnicities::MAPPING)
    end

    def ethnicity_and_disability_attributes
      ethnicity_attributes.merge(disability_attributes)
    end

    def course_attributes
      {
        course_subject_one: course(placement_assignment.response["_dfe_ittsubject1id_value"]),
        course_subject_two: course(placement_assignment.response["_dfe_ittsubject2id_value"]),
        course_subject_three: course(placement_assignment.response["_dfe_ittsubject3id_value"]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        study_mode: study_mode,
        commencement_date: placement_assignment.response["dfe_commencementdate"],
        course_start_date: placement_assignment.response["dfe_programmestartdate"],
        course_end_date: placement_assignment.response["dfe_programmeeenddate"],
      }
    end

    def course(dttp_course_uuid)
      find_by_entity_id(dttp_course_uuid, Dttp::CodeSets::CourseSubjects::MAPPING)
    end

    def age_range
      @age_range ||= find_by_entity_id(placement_assignment.response["_dfe_coursephaseid_value"], Dttp::CodeSets::AgeRanges::MAPPING)
    end

    def study_mode
      find_by_entity_id(placement_assignment.response["_dfe_studymodeid_value"], Dttp::CodeSets::CourseStudyModes::MAPPING)
    end

    def find_by_entity_id(id, mapping)
      mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
    end
  end
end
