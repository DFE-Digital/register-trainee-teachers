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
      return if dttp_trainee.imported?
      return if dttp_trainee.provider.blank?
      return if latest_placement_assignment.blank?

      if multiple_providers?
        dttp_trainee.non_importable_multi_provider!
        return
      end

      if multiple_courses?
        dttp_trainee.non_importable_multi_course!
        return
      end

      if training_route.blank?
        dttp_trainee.non_importable_missing_route!
        return
      end

      if unmapped_training_initiative?
        dttp_trainee.non_importable_missing_initiative!
        return
      end

      if trainee_status.blank?
        dttp_trainee.non_importable_missing_state!
        return
      end

      if training_route == TRAINING_ROUTE_ENUMS[:hpitt_postgrad]
        dttp_trainee.non_importable_hpitt!
        return
      end

      if funding_not_yet_mapped?
        dttp_trainee.non_importable_missing_funding!
        return
      end

      if trainee_already_exists?
        dttp_trainee.non_importable_duplicate!
        return
      end

      trainee.save!

      calculate_funding!

      enqueue_background_jobs!

      create_degrees!

      dttp_trainee.imported!

      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      return if latest_placement_assignment.blank?

      {
        created_from_dttp: true,
        state: trainee_status,
        provider: dttp_trainee.provider,
        trainee_id: trainee_id,
        training_route: training_route,
        trn: dttp_trainee.response["dfe_trn"],
        submitted_for_trn_at: earliest_placement_assignment.response["dfe_trnassessmentdate"],
        dttp_id: dttp_trainee.dttp_id,
        placement_assignment_dttp_id: latest_placement_assignment.dttp_id,
      }.merge(personal_details_attributes)
       .merge(contact_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
    end

    def create_degrees!
      ::Degrees::CreateFromDttp.call(trainee: trainee)
    end

    def earliest_placement_assignment
      @earliest_placement_assignment ||= sorted_placement_assignments.first
    end

    def latest_placement_assignment
      @latest_placement_assignment ||= sorted_placement_assignments.last
    end

    def sorted_placement_assignments
      @sorted_placement_assignments ||= dttp_trainee.placement_assignments.where.not(programme_start_date: nil).order(:programme_start_date)
    end

    def multiple_providers?
      dttp_trainee.placement_assignments.map(&:provider_dttp_id).uniq != [dttp_trainee.provider_dttp_id]
    end

    def multiple_courses?
      dttp_trainee.placement_assignments.map { |placement_assignment| placement_assignment.response["_dfe_ittsubject1id_value"] }.uniq.count > 1
    end

    def trainee_already_exists?
      Trainee.exists?(dttp_id: dttp_trainee.dttp_id)
    end

    def training_route
      @training_route ||= if dttp_route == TRAINING_ROUTE_ENUMS[:provider_led_postgrad] && undergrad_level?
                            TRAINING_ROUTE_ENUMS[:provider_led_undergrad]
                          elsif dttp_route == ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]
                            TRAINING_ROUTE_ENUMS[:school_direct_salaried]
                          else
                            dttp_route
                          end
    end

    def dttp_route
      @dttp_route ||= find_by_entity_id(
        latest_placement_assignment.route_dttp_id,
        Dttp::CodeSets::Routes::MAPPING,
      )
    end

    def undergrad_level?
      latest_placement_assignment.response["dfe_courselevel"] == Dttp::Params::PlacementAssignment::COURSE_LEVEL_UG
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
      course_subject_one_name = course(latest_placement_assignment.response["_dfe_ittsubject1id_value"])

      {
        course_education_phase: course_education_phase(course_subject_one_name),
        course_subject_one: course_subject_one_name,
        course_subject_two: course(latest_placement_assignment.response["_dfe_ittsubject2id_value"]),
        course_subject_three: course(latest_placement_assignment.response["_dfe_ittsubject3id_value"]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        study_mode: study_mode,
        commencement_date: earliest_placement_assignment.response["dfe_commencementdate"],
        itt_start_date: latest_placement_assignment.programme_start_date,
        itt_end_date: latest_placement_assignment.programme_end_date,
      }
    end

    def course(dttp_course_uuid)
      find_by_entity_id(
        dttp_course_uuid,
        Dttp::CodeSets::CourseSubjects::MAPPING,
      )
    end

    def course_education_phase(subject_name)
      return if subject_name.blank?

      return COURSE_EDUCATION_PHASE_ENUMS[:primary] if [
        CourseSubjects::PRIMARY_TEACHING,
        CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS,
      ].include?(subject_name)

      COURSE_EDUCATION_PHASE_ENUMS[:secondary]
    end

    def age_range
      @age_range ||= find_by_entity_id(
        latest_placement_assignment.response["_dfe_coursephaseid_value"],
        Dttp::CodeSets::AgeRanges::MAPPING,
      )
    end

    def study_mode
      find_by_entity_id(
        latest_placement_assignment.response["_dfe_studymodeid_value"],
        Dttp::CodeSets::CourseStudyModes::MAPPING,
      )
    end

    def school_attributes
      return {} if latest_placement_assignment.lead_school_id.blank?

      # Should we raise when schools are not found so that we can add them?
      attrs = {
        lead_school: School.find_by(urn: lead_school_urn),
      }

      if latest_placement_assignment.employing_school_id.present?
        attrs.merge!({
          employing_school: School.find_by(urn: employing_school_urn),
        })
      end

      attrs
    end

    def training_initiative_attributes
      {
        training_initiative: training_initiative,
      }
    end

    def training_initiative
      if dttp_route == ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]
        return ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]
      end

      find_by_entity_id(
        latest_placement_assignment.response["_dfe_initiative1id_value"],
        Dttp::CodeSets::TrainingInitiatives::MAPPING,
      )
    end

    def unmapped_training_initiative?
      latest_placement_assignment.response["_dfe_initiative1id_value"].present? && training_initiative.blank?
    end

    def lead_school_urn
      Dttp::School.find_by(dttp_id: latest_placement_assignment.lead_school_id)&.urn
    end

    def employing_school_urn
      Dttp::School.find_by(dttp_id: latest_placement_assignment.employing_school_id)&.urn
    end

    def funding_attributes
      return {} if latest_placement_assignment.response["dfe_allocatedplace"] == Dttp::Params::PlacementAssignment::NO_ALLOCATED_PLACE

      if funding_entity_id == Dttp::Params::PlacementAssignment::SCHOLARSHIP
        return { applying_for_scholarship: true }
      end

      if funding_manager.can_apply_for_tiered_bursary?
        return { applying_for_bursary: true, bursary_tier: route_or_tier_for_funding }
      end

      {
        applying_for_grant: funding_manager.can_apply_for_grant?,
        applying_for_scholarship: funding_manager.can_apply_for_scholarship?,
        applying_for_bursary: funding_manager.can_apply_for_bursary?,
      }.reject { |_key, value| value == false }
    end

    def route_or_tier_for_funding
      find_by_entity_id(
        funding_entity_id,
        Dttp::CodeSets::BursaryDetails::MAPPING,
      )
    end

    def funding_entity_id
      latest_placement_assignment.response["_dfe_bursarydetailsid_value"]
    end

    def funding_not_yet_mapped?
      funding_entity_id.present? && funding_attributes.compact.blank?
    end

    def trainee_status
      case dttp_trainee_status
      when DttpStatuses::DRAFT_RECORD then "draft"
      when DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED then "submitted_for_trn"
      when DttpStatuses::STANDARDS_MET then "recommended_for_award"
      when DttpStatuses::DEFERRED then "deferred"
      when DttpStatuses::YET_TO_COMPLETE_COURSE then "trn_received"
      when (DttpStatuses::AWARDED_EYTS || DttpStatuses::AWARDED_QTS) then "awarded"
      when DttpStatuses::LEFT_COURSE_BEFORE_END then "withdrawn"
      when (DttpStatuses::AWAITING_QTS || DttpStatuses::EYTS_REVOKED || DttpStatuses::QTS_REVOKED || DttpStatuses::STANDARDS_NOT_MET || DttpStatuses::DID_NOT_START || DttpStatuses::REJECTED) then nil
      end
    end

    def enqueue_background_jobs!
      Dttp::RetrieveTrnJob.perform_with_default_delay(trainee) if trainee.submitted_for_trn?
      Dttp::RetrieveAwardJob.perform_with_default_delay(trainee) if trainee.recommended_for_award?
    end

    def calculate_funding!
      trainee.update!(funding_attributes) if funding_manager.can_apply_for_funding_type?
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end

    def dttp_trainee_status
      find_by_entity_id(
        latest_placement_assignment.response["_dfe_traineestatusid_value"],
        Dttp::CodeSets::Statuses::MAPPING,
      )
    end

    def find_by_entity_id(id, mapping)
      mapping.select { |_key, value| value[:entity_id] == id }.keys&.first
    end
  end
end
