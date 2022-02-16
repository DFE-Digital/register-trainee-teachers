# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern
    include HasDttpMapping
    include DiversityAttributes

    TRN_REGEX = /^(\d{6,7})$/.freeze

    UK_COUNTRIES = ["England", "United Kingdom", "Scotland", "Northern Ireland",
                    "Wales", "Isle of Man",
                    "United Kingdom, not otherwise specified"].freeze

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
      @trainee = Trainee.new(mapped_attributes)
    end

    def call
      return if dttp_trainee.imported?
      return if dttp_trainee.provider.blank?
      return if dttp_trainee.placement_assignments.blank?
      return if dttp_trainee.response["merged"]

      if trainee_already_exists?
        dttp_trainee.non_importable_duplicate!
        return
      end

      if multiple_providers?
        dttp_trainee.non_importable_multi_provider!
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

      trainee.set_early_years_course_details

      trainee.save!

      add_multiple_disability_text!

      enqueue_background_jobs!

      create_degrees!

      dttp_trainee.imported!

      update_dttp_sha!

      set_created_at_and_updated_at!
      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      return if dttp_trainee.placement_assignments.blank?

      {
        created_from_dttp: true,
        state: trainee_status,
        provider: dttp_trainee.provider,
        trainee_id: trainee_id,
        training_route: training_route,
        trn: trn,
        submitted_for_trn_at: dttp_trainee.earliest_placement_assignment.response["dfe_trnassessmentdate"],
        outcome_date: dttp_trainee.latest_placement_assignment.response["dfe_datestandardsassessmentpassed"],
        awarded_at: dttp_trainee.latest_placement_assignment.response["dfe_qtseytsawarddate"],
        dttp_id: dttp_trainee.dttp_id,
        placement_assignment_dttp_id: dttp_trainee.latest_placement_assignment.dttp_id,
        hesa_id: dttp_trainee.hesa_id,
      }.merge(personal_details_attributes)
       .merge(contact_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
       .merge(withdrawal_attributes)
       .merge(deferral_attributes)
       .merge(funding_attributes)
    end

    def create_degrees!
      ::Degrees::CreateFromDttp.call(trainee: trainee)
    end

    def multiple_providers?
      dttp_trainee.latest_placement_assignment.provider_dttp_id != dttp_trainee.provider_dttp_id
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
        dttp_trainee.latest_placement_assignment.route_dttp_id,
        Dttp::CodeSets::Routes::MAPPING,
      )
    end

    def undergrad_level?
      dttp_trainee.latest_placement_assignment.response["dfe_courselevel"] == Dttp::Params::PlacementAssignment::COURSE_LEVEL_UG
    end

    def trn
      dttp_trainee.trn if TRN_REGEX.match?(dttp_trainee.trn)
    end

    def trainee_gender
      return :gender_not_provided if dttp_trainee.gender_code.blank?

      return :other if Dttp::Params::Contact::OTHER_GENDER_CODE == dttp_trainee.gender_code.to_i

      Dttp::Params::Contact::GENDER_CODES.invert[dttp_trainee.gender_code.to_i]
    end

    def trainee_id
      return if dttp_trainee.response["dfe_traineeid"] == Dttp::Params::Contact::NOT_PROVIDED

      dttp_trainee.response["dfe_traineeid"]
    end

    def nationalities
      Nationality.where(name: nationality_name)
    end

    def nationality_name
      return Dttp::CodeSets::Nationalities::BRITISH if Dttp::CodeSets::Nationalities::UK_NATIONALITIES.include?(dttp_nationality_name)

      nationality_name_from_ambiguous_mapping.presence || dttp_nationality_name
    end

    def nationality_name_from_ambiguous_mapping
      Dttp::CodeSets::Nationalities::AMBIGUOUS_NATIONALITY_MAPPINGS.select { |_key, values| values.include?(dttp_nationality_name) }.keys.first
    end

    def dttp_nationality_name
      @dttp_nationality_name ||=
        find_by_entity_id(dttp_trainee.nationality, Dttp::CodeSets::Nationalities::MAPPING) ||
          find_by_entity_id(dttp_trainee.nationality, Dttp::CodeSets::Nationalities::INACTIVE_MAPPING)
    end

    def disability
      @disability ||= find_by_entity_id(
        dttp_trainee.response["_dfe_disibilityid_value"],
        Dttp::CodeSets::Disabilities::MAPPING,
      )
    end

    def ethnic_background
      find_by_entity_id(dttp_trainee.ethnicity, Dttp::CodeSets::Ethnicities::MAPPING) ||
        find_by_entity_id(dttp_trainee.ethnicity, Dttp::CodeSets::Ethnicities::INACTIVE_MAPPING)
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

    def address_attributes
      if UK_COUNTRIES.include?(dttp_trainee.country) || valid_postcode?
        return {
          locale_code: Trainee.locale_codes[:uk],
          address_line_one: dttp_trainee.response["address1_line1"],
          address_line_two: dttp_trainee.response["address1_line2"],
          town_city: dttp_trainee.response["address1_line3"],
          postcode: dttp_trainee.response["address1_postalcode"],
        }
      end

      if dttp_trainee.country.present? && !UK_COUNTRIES.include?(dttp_trainee.country)
        return {
          locale_code: Trainee.locale_codes[:non_uk],
          international_address: dttp_trainee.response["address1_composite"],
        }
      end

      {}
    end

    def valid_postcode?
      dttp_trainee.postcode && UKPostcode.parse(dttp_trainee.postcode).valid?
    end

    def contact_attributes
      address_attributes.merge({
        email: dttp_trainee.response["emailaddress1"],
      })
    end

    def course_attributes
      {
        course_education_phase: course_education_phase(course_subject_one_name),
        course_subject_one: course_subject_one_name,
        course_subject_two: course(dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject2id_value"]),
        course_subject_three: course(dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject3id_value"]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        study_mode: study_mode,
        commencement_date: commencement_date,
        itt_start_date: dttp_trainee.latest_placement_assignment.programme_start_date,
        itt_end_date: dttp_trainee.latest_placement_assignment.programme_end_date,
      }
    end

    def course_subject_one_name
      return CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS if primary_mathematics_specialism?

      course(dttp_trainee.latest_placement_assignment.response["_dfe_ittsubject1id_value"])
    end

    def commencement_date
      dttp_trainee.latest_placement_assignment.response["dfe_commencementdate"] || dttp_trainee.latest_placement_assignment.programme_start_date
    end

    def course(dttp_course_uuid)
      find_by_entity_id(dttp_course_uuid, Dttp::CodeSets::CourseSubjects::MAPPING) ||
        find_by_entity_id(dttp_course_uuid, Dttp::CodeSets::CourseSubjects::INACTIVE_MAPPING)
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
        dttp_trainee.latest_placement_assignment.response["_dfe_coursephaseid_value"],
        Dttp::CodeSets::AgeRanges::MAPPING,
      )
    end

    def study_mode
      study_mode_id = dttp_trainee.latest_placement_assignment.study_mode_id

      if Dttp::CodeSets::CourseStudyModes::OTHER_FULL_TIME_MODES.include?(study_mode_id)
        return COURSE_STUDY_MODES[:full_time]
      end

      if Dttp::CodeSets::CourseStudyModes::OTHER_PART_TIME_MODES.include?(study_mode_id)
        return COURSE_STUDY_MODES[:part_time]
      end

      find_by_entity_id(study_mode_id, Dttp::CodeSets::CourseStudyModes::MAPPING)
    end

    def school_attributes
      return {} if dttp_trainee.latest_placement_assignment.lead_school_id.blank?

      # Should we raise when schools are not found so that we can add them?
      attrs = {
        lead_school: School.find_by(urn: lead_school_urn),
      }

      if dttp_trainee.latest_placement_assignment.employing_school_id.present?
        attrs.merge!({
          employing_school: School.find_by(urn: employing_school_urn),
        })
      end

      attrs
    end

    def training_initiative_attributes
      {
        training_initiative: training_initiative.presence || ROUTE_INITIATIVES_ENUMS[:no_initiative],
        ebacc: ebacc?,
      }
    end

    def training_initiative
      if dttp_route == ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]
        return ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars]
      end

      return if primary_mathematics_specialism?

      find_by_entity_id(dttp_initiative_id, Dttp::CodeSets::TrainingInitiatives::MAPPING)
    end

    def unmapped_training_initiative?
      dttp_initiative_id.present? && !special_initiatives? && training_initiative.blank?
    end

    def special_initiatives?
      ebacc? || primary_mathematics_specialism?
    end

    def primary_mathematics_specialism?
      [
        Dttp::CodeSets::TrainingInitiatives::PRIMARY_MATHEMATICS_SPECIALISM,
        Dttp::CodeSets::TrainingInitiatives::PRIMARY_GENERAL_WITH_MATHS,
      ].include?(dttp_initiative_id)
    end

    def ebacc?
      dttp_initiative_id == Dttp::CodeSets::TrainingInitiatives::EBACC
    end

    def dttp_initiative_id
      @dttp_initiative_id ||= dttp_trainee.latest_placement_assignment.response["_dfe_initiative1id_value"]
    end

    def lead_school_urn
      Dttp::School.find_by(dttp_id: dttp_trainee.latest_placement_assignment.lead_school_id)&.urn
    end

    def employing_school_urn
      Dttp::School.find_by(dttp_id: dttp_trainee.latest_placement_assignment.employing_school_id)&.urn
    end

    def trainee_status
      @trainee_status ||= MapStateFromDttp.call(dttp_trainee: dttp_trainee)
    end

    def withdrawal_attributes
      return {} unless trainee_status == "withdrawn"

      {
        withdraw_date: withdraw_date,
        withdraw_reason: withdraw_reason || WithdrawalReasons::FOR_ANOTHER_REASON,
      }
    end

    def deferral_attributes
      return {} if dttp_trainee.latest_placement_assignment.dormant_period.blank?

      {
        defer_date: dttp_trainee.latest_placement_assignment.dormant_period.date_left,
        reinstate_date: dttp_trainee.latest_placement_assignment.dormant_period.date_returned,
        dormancy_dttp_id: dttp_trainee.latest_placement_assignment.dormant_period.dttp_id,
      }
    end

    def withdraw_date
      dttp_trainee.latest_placement_assignment.response["dfe_dateleft"]
    end

    def withdraw_reason
      find_by_entity_id(
        dttp_trainee.latest_placement_assignment.response["_dfe_reasonforleavingid_value"],
        Dttp::CodeSets::ReasonsForLeavingCourse::MAPPING,
      )
    end

    def enqueue_background_jobs!
      Dttp::RetrieveTrnJob.perform_with_default_delay(trainee) if trainee.submitted_for_trn?
      Dttp::RetrieveAwardJob.perform_with_default_delay(trainee) if trainee.recommended_for_award?
    end

    def funding_attributes
      @funding_attributes ||= MapFundingFromDttp.call(dttp_trainee: dttp_trainee)
    end

    def update_dttp_sha!
      trainee.dttp_update_sha = trainee.sha

      trainee.save!
    end

    def set_created_at_and_updated_at!
      trainee.update!(created_at: dttp_trainee.created_at)
      trainee.update!(updated_at: dttp_trainee.updated_at)
    end
  end
end
