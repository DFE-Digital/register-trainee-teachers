# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern
    include HasDttpMapping
    include HasDiversityAttributes

    TRN_REGEX = /^(\d{6,7})$/

    UK_COUNTRIES = ["England", "United Kingdom", "Scotland", "Northern Ireland",
                    "Wales", "Isle of Man",
                    "United Kingdom, not otherwise specified"].freeze

    NOT_APPLICABLE_SCHOOL_URNS = %w[900010 99999996].freeze

    NOT_PROVIDED = "NOTPROVIDED"

    OTHER_GENDER_CODE = 389_040_000

    SEX_CODES = {
      male: 1,
      female: 2,
      other: OTHER_GENDER_CODE,
      sex_not_provided: OTHER_GENDER_CODE,
    }.freeze

    POSTGRAD_CODE = 12
    UNDERGRAD_CODE = 20

    MULTIPLE_DISABILITIES_TEXT = "HESA multiple disabilities"

    def initialize(dttp_trainee:, placement_assignment: nil)
      @dttp_trainee = dttp_trainee
      @placement_assignment = placement_assignment || dttp_trainee.latest_placement_assignment
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

      if trainee_state.blank?
        dttp_trainee.non_importable_missing_state!
        return
      end

      trainee.set_early_years_course_details

      trainee.save!

      add_multiple_disability_text!

      enqueue_background_jobs!

      create_degrees!

      dttp_trainee.imported!

      update_shases!

      set_created_at_and_updated_at!
      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee, :placement_assignment

    def mapped_attributes
      return if dttp_trainee.placement_assignments.blank?

      {
        created_from_dttp: true,
        state: trainee_state,
        provider: dttp_trainee.provider,
        trainee_id: trainee_id,
        training_route: training_route,
        trn: trn,
        submitted_for_trn_at: dttp_trainee.earliest_placement_assignment.response["dfe_trnassessmentdate"],
        outcome_date: placement_assignment.response["dfe_datestandardsassessmentpassed"],
        awarded_at: placement_assignment.response["dfe_qtseytsawarddate"],
        dttp_id: dttp_trainee.dttp_id,
        placement_assignment_dttp_id: placement_assignment.dttp_id,
        hesa_id: dttp_trainee.hesa_id,
        record_source: RecordSources::DTTP,
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
      ::Degrees::CreateFromDttp.call(trainee:)
    end

    def multiple_providers?
      placement_assignment.provider_dttp_id != dttp_trainee.provider_dttp_id
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
        placement_assignment.route_dttp_id,
        Dttp::CodeSets::Routes::MAPPING,
      ) || find_by_entity_id(
        placement_assignment.route_dttp_id,
        Dttp::CodeSets::Routes::INACTIVE_MAPPING,
      )
    end

    def undergrad_level?
      placement_assignment.response["dfe_courselevel"] == UNDERGRAD_CODE
    end

    def trn
      dttp_trainee.trn if TRN_REGEX.match?(dttp_trainee.trn)
    end

    def trainee_gender
      return :sex_not_provided if dttp_trainee.gender_code.blank?

      return :other if dttp_trainee.gender_code.to_i == OTHER_GENDER_CODE

      SEX_CODES.invert[dttp_trainee.gender_code.to_i]
    end

    def trainee_id
      return if dttp_trainee.response["dfe_traineeid"] == NOT_PROVIDED

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
        sex: trainee_gender,
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

      if dttp_trainee.country.present? && UK_COUNTRIES.exclude?(dttp_trainee.country)
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
        course_subject_two: course(placement_assignment.response["_dfe_ittsubject2id_value"]),
        course_subject_three: course(placement_assignment.response["_dfe_ittsubject3id_value"]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        course_allocation_subject: course_allocation_subject,
        study_mode: study_mode,
        trainee_start_date: trainee_start_date,
        itt_start_date: placement_assignment.programme_start_date,
        itt_end_date: placement_assignment.programme_end_date,
      }
    end

    def course_subject_one_name
      return CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS if primary_mathematics_specialism?

      course(placement_assignment.response["_dfe_ittsubject1id_value"])
    end

    def trainee_start_date
      placement_assignment.response["dfe_commencementdate"] || placement_assignment.programme_start_date
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
        placement_assignment.response["_dfe_coursephaseid_value"],
        Dttp::CodeSets::AgeRanges::MAPPING,
      )
    end

    def study_mode
      study_mode_id = placement_assignment.study_mode_id

      if Dttp::CodeSets::CourseStudyModes::OTHER_FULL_TIME_MODES.include?(study_mode_id)
        return COURSE_STUDY_MODES[:full_time]
      end

      if Dttp::CodeSets::CourseStudyModes::OTHER_PART_TIME_MODES.include?(study_mode_id)
        return COURSE_STUDY_MODES[:part_time]
      end

      find_by_entity_id(study_mode_id, Dttp::CodeSets::CourseStudyModes::MAPPING)
    end

    def school_attributes
      return {} if placement_assignment.lead_school_id.blank?

      # Should we raise when schools are not found so that we can add them?
      if NOT_APPLICABLE_SCHOOL_URNS.include?(lead_school_urn)
        attrs = {
          lead_school_not_applicable: true,
        }
      else
        attrs = {
          lead_school: School.find_by(urn: lead_school_urn),
        }
      end

      if placement_assignment.employing_school_id.present?
        if NOT_APPLICABLE_SCHOOL_URNS.include?(employing_school_urn)
          attrs.merge!({
            employing_school_not_applicable: true,
          })
        else
          attrs.merge!({
            employing_school: School.find_by(urn: employing_school_urn),
          })
        end
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
      @dttp_initiative_id ||= placement_assignment.response["_dfe_initiative1id_value"]
    end

    def lead_school_urn
      Dttp::School.find_by(dttp_id: placement_assignment.lead_school_id)&.urn
    end

    def employing_school_urn
      Dttp::School.find_by(dttp_id: placement_assignment.employing_school_id)&.urn
    end

    def trainee_state
      @trainee_state ||= MapStateFromDttp.call(dttp_trainee:)
    end

    def withdrawal_attributes
      return {} unless trainee_state == "withdrawn"

      {
        withdraw_date: withdraw_date,
        withdraw_reason: withdraw_reason || WithdrawalReasons::FOR_ANOTHER_REASON,
      }
    end

    def deferral_attributes
      return {} if placement_assignment.dormant_period.blank?

      {
        defer_date: placement_assignment.dormant_period.date_left,
        reinstate_date: placement_assignment.dormant_period.date_returned,
        dormancy_dttp_id: placement_assignment.dormant_period.dttp_id,
      }
    end

    def withdraw_date
      placement_assignment.response["dfe_dateleft"]
    end

    def withdraw_reason
      find_by_entity_id(
        placement_assignment.response["_dfe_reasonforleavingid_value"],
        Dttp::CodeSets::ReasonsForLeavingCourse::MAPPING,
      )
    end

    def enqueue_background_jobs!
      Dqt::RetrieveTrnJob.perform_later(trainee) if trainee.submitted_for_trn?
    end

    def funding_attributes
      @funding_attributes ||= MapFundingFromDttpEntityId.call(funding_entity_id:)
    end

    def funding_entity_id
      @funding_entity_id ||= placement_assignment.funding_id
    end

    def course_allocation_subject
      SubjectSpecialism.find_by(name: course_subject_one_name)&.allocation_subject
    end

    def update_shases!
      sha = trainee.sha
      trainee.dttp_update_sha = sha

      trainee.save!
    end

    def set_created_at_and_updated_at!
      trainee.update!(created_at: dttp_trainee.created_at)
      trainee.update!(updated_at: dttp_trainee.updated_at)
    end

    def ethnicity_attributes
      if Diversities::NOT_PROVIDED_ETHNICITIES.include?(ethnic_background)
        return {
          ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
          ethnic_background: Diversities::NOT_PROVIDED,
        }
      end

      if Diversities::WHITE_ETHNICITIES.include?(ethnic_background)
        return {
          ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:white],
          ethnic_background: Diversities::NOT_PROVIDED,
        }
      end

      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

        return {
          ethnic_group:,
          ethnic_background:,
        }
      end

      {
        ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        ethnic_background: Diversities::NOT_PROVIDED,
      }
    end

    def disability_attributes
      if disability.blank? || disability == Diversities::NOT_PROVIDED
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
        }
      end

      if disability == Diversities::NO_KNOWN_DISABILITY
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
        }
      end

      if disability == Diversities::MULTIPLE_DISABILITIES
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
          disabilities: Disability.where(name: ::Diversities::OTHER),
        }
      end

      {
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        disabilities: Disability.where(name: disability),
      }
    end

    def diversity_disclosure
      if disability.present? || ethnicity_disclosed?
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      else
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
      end
    end

    def add_multiple_disability_text!
      return unless disability == Diversities::MULTIPLE_DISABILITIES

      trainee.trainee_disabilities.last.update!(additional_disability: MULTIPLE_DISABILITIES_TEXT)
    end
  end
end
