# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern

    class UnrecognisedStatusError < StandardError; end

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
      @trainee = Trainee.new(mapped_attributes)
    end

    def call
      return if dttp_trainee.provider.blank?
      return if placement_assignment.blank?

      if training_route.blank?
        dttp_trainee.non_processable_missing_route!
        return
      end

      if trainee_already_exists?
        dttp_trainee.non_processable_duplicate!
        return
      end

      trainee.save!
      create_degrees!

      # TODO: TBC what states are we going to use
      dttp_trainee.processed!

      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      {
        state: trainee_status,
        provider: dttp_trainee.provider,
        trainee_id: trainee_id,
        training_route: training_route,
        trn: dttp_trainee.response["dfe_trn"],
        submitted_for_trn_at: placement_assignment.response["dfe_trnassessmentdate"],
        dttp_id: dttp_trainee.dttp_id,
        placement_assignment_dttp_id: placement_assignment.dttp_id,
      }.merge(personal_details_attributes)
       .merge(contact_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(school_attributes)
       .merge(funding_attributes)
    end

    def create_degrees!
      ::Degrees::CreateFromDttp.call(trainee: trainee)
    end

    def placement_assignment
      @placement_assignment ||= dttp_trainee.placement_assignments.first
    end

    def trainee_already_exists?
      Trainee.exists?(dttp_id: dttp_trainee.dttp_id)
    end

    def training_route
      @training_route ||= find_by_entity_id(
        placement_assignment.route_dttp_id,
        Dttp::CodeSets::Routes::MAPPING,
      )
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
        find_by_entity_id(
          dttp_trainee.response["_dfe_nationality_value"],
          Dttp::CodeSets::Nationalities::MAPPING,
        ),
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
      @disability ||= find_by_entity_id(
        dttp_trainee.response["_dfe_disibilityid_value"],
        Dttp::CodeSets::Disabilities::MAPPING,
      )
    end

    def ethnicity_attributes
      ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

      if ethnic_background.present? && ethnic_background != Diversities::NOT_PROVIDED
        diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      else
        diversity_disclosure = Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
      end

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
      @ethnic_background ||= find_by_entity_id(
        dttp_trainee.response["_dfe_ethnicityid_value"],
        Dttp::CodeSets::Ethnicities::MAPPING,
      )
    end

    def ethnicity_and_disability_attributes
      ethnicity_attributes.merge(disability_attributes)
    end

    def personal_details_attributes
      {
        first_names: dttp_trainee.response["firstname"],
        middle_names: dttp_trainee.response["middlename"],
        last_name: dttp_trainee.response["lastname"],
        date_of_birth: dttp_trainee.date_of_birth,
        gender: trainee_gender,
        nationalities: nationalities,
      }
    end

    def locale_code
      return {} if dttp_trainee.response["address1_line1"].blank?

      { locale_code: Trainee.locale_codes[:uk] }
    end

    def contact_attributes
      {
        address_line_one: dttp_trainee.response["address1_line1"],
        address_line_two: dttp_trainee.response["address1_line2"],
        town_city: dttp_trainee.response["address1_line3"],
        postcode: dttp_trainee.response["address1_postalcode"],
        email: dttp_trainee.response["emailaddress1"],
      }.merge(locale_code)
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
      find_by_entity_id(
        dttp_course_uuid,
        Dttp::CodeSets::CourseSubjects::MAPPING,
      )
    end

    def age_range
      @age_range ||= find_by_entity_id(
        placement_assignment.response["_dfe_coursephaseid_value"],
        Dttp::CodeSets::AgeRanges::MAPPING,
      )
    end

    def study_mode
      find_by_entity_id(
        placement_assignment.response["_dfe_studymodeid_value"],
        Dttp::CodeSets::CourseStudyModes::MAPPING,
      )
    end

    def school_attributes
      return {} if placement_assignment.lead_school_id.blank?

      # Should we raise when schools are not found so that we can add them?
      attrs = {
        lead_school: School.find_by(urn: lead_school_urn),
      }

      if placement_assignment.employing_school_id.present?
        attrs.merge!({
          employing_school: School.find_by(urn: employing_school_urn),
        })
      end

      attrs
    end

    def lead_school_urn
      Dttp::School.find_by(dttp_id: placement_assignment.lead_school_id)&.urn
    end

    def employing_school_urn
      Dttp::School.find_by(dttp_id: placement_assignment.employing_school_id)&.urn
    end

    def funding_attributes
      return {} unless placement_assignment.response["dfe_allocatedplace"] == Dttp::Params::PlacementAssignment::ALLOCATED_PLACE

      if placement_assignment.response["_dfe_bursarydetailsid_value"] == Dttp::Params::PlacementAssignment::SCHOLARSHIP
        return { applying_for_scholarship: true }
      end

      funding_method = FundingMethod.find_by(training_route: training_route_for_funding)

      {
        applying_for_grant: funding_method&.grant?,
        applying_for_scholarship: funding_method&.scholarship?,
        applying_for_bursary: funding_method&.bursary?,
      }
    end

    def training_route_for_funding
      find_by_entity_id(
        placement_assignment.response["_dfe_bursarydetailsid_value"],
        Dttp::CodeSets::BursaryDetails::MAPPING,
      )
    end

    def trainee_status
      case dttp_trainee_status
      when DttpStatuses::DRAFT_RECORD then "draft"
      when DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED then "submitted_for_trn"
      when DttpStatuses::DEFERRED then "deferred"
      when DttpStatuses::YET_TO_COMPLETE_COURSE then "trn_received"
      when (DttpStatuses::AWARDED_EYTS || DttpStatuses::AWARDED_QTS) then "awarded"
      when DttpStatuses::LEFT_COURSE_BEFORE_END then "withdrawn"
      else
        # Raise if it's something else? Are we expecting other statuses?
        # What if it's AWAITING_QTS or PROSPECTIVE_TRAINEE_TRN_REQUESTED? Should
        # we import and kick off respective jobs?
        raise(UnrecognisedStatusError, "Trainee status with dttp status id #{placement_assignment.response['_dfe_traineestatusid_value']} is not yet mapped")
      end
    end

    def dttp_trainee_status
      find_by_entity_id(
        placement_assignment.response["_dfe_traineestatusid_value"],
        Dttp::CodeSets::Statuses::MAPPING,
      )
    end

    def find_by_entity_id(id, mapping)
      mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
    end
  end
end
