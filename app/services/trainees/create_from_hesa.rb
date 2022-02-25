# frozen_string_literal: true

module Trainees
  class CreateFromHesa
    include ServicePattern
    include DiversityAttributes

    USERNAME = "HESA"

    def initialize(student_node:)
      @hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)
      @trainee = Trainee.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
    end

    def call
      Audited.audit_class.as_user(USERNAME) do
        trainee.assign_attributes(mapped_attributes)

        if trainee.save!
          create_degrees!
          add_multiple_disability_text!
        end
      end

      [trainee, hesa_trainee[:ukprn]]
    end

  private

    attr_reader :hesa_trainee, :trainee

    def mapped_attributes
      {
        created_from_hesa: trainee.id.blank?,
        trainee_id: hesa_trainee[:trainee_id],
        training_route: training_route,
      }.merge(personal_details_attributes)
       .merge(contact_attributes)
       .merge(provider_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(deferral_attributes)
       .merge(withdrawal_attributes)
       .merge(funding_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
    end

    def personal_details_attributes
      {
        first_names: hesa_trainee[:first_names],
        last_name: hesa_trainee[:last_name],
        date_of_birth: hesa_trainee[:date_of_birth],
        gender: hesa_trainee[:gender].to_i,
        nationalities: nationalities,
      }
    end

    def contact_attributes
      {
        email: hesa_trainee[:email],
        address_line_one: hesa_trainee[:address_line_one],
        address_line_two: hesa_trainee[:address_line_two],
      }
    end

    def provider_attributes
      provider = Provider.find_by(ukprn: hesa_trainee[:ukprn])
      provider ? { provider: provider } : {}
    end

    def course_attributes
      {
        course_education_phase: course_education_phase,
        course_subject_one: course_subject_one_name,
        course_subject_two: course_subject_name(hesa_trainee[:course_subject_two]),
        course_subject_three: course_subject_name(hesa_trainee[:course_subject_three]),
        course_min_age: age_range && age_range[0],
        course_max_age: age_range && age_range[1],
        study_mode: study_mode,
        itt_start_date: hesa_trainee[:itt_start_date],
        itt_end_date: hesa_trainee[:itt_end_date],
        commencement_date: hesa_trainee[:commencement_date] || hesa_trainee[:itt_start_date],
      }
    end

    def deferral_attributes
      return {} unless trainee_deferred?

      {
        defer_date: hesa_trainee[:end_date],
        state: "deferred",
      }
    end

    def trainee_deferred?
      completion_of_course_result_unknown? &&
      [
        Hesa::CodeSets::Modes::DORMANT_FULL_TIME,
        Hesa::CodeSets::Modes::DORMANT_PART_TIME,
      ].include?(mode)
    end

    def withdrawal_attributes
      return {} unless trainee_withdrawn?

      {
        withdraw_date: hesa_trainee[:end_date],
        withdraw_reason: reason_for_leaving,
        state: "withdrawn",
      }
    end

    def trainee_withdrawn?
      hesa_trainee[:end_date].present? && reasons_for_leaving_indicate_withdrawal?
    end

    def reasons_for_leaving_indicate_withdrawal?
      [
        successful_completion_of_course?,
        completion_of_course_result_unknown?,
      ].none?
    end

    def successful_completion_of_course?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::SUCCESSFUL_COMPLETION
    end

    def completion_of_course_result_unknown?
      reason_for_leaving == Hesa::CodeSets::ReasonsForLeavingCourse::UNKNOWN_COMPLETION
    end

    def funding_attributes
      @funding_attributes ||= MapFundingFromDttpEntityId.call(funding_entity_id: funding_entity_id)
    end

    def school_attributes
      return {} if hesa_trainee[:lead_school_urn].blank?

      attrs = { lead_school: School.find_by(urn: hesa_trainee[:lead_school_urn]) }

      if hesa_trainee[:employing_school_urn].present?
        attrs.merge!({ employing_school: School.find_by(urn: hesa_trainee[:employing_school_urn]) })
      end

      attrs
    end

    def training_initiative_attributes
      { training_initiative: training_initiative || ROUTE_INITIATIVES_ENUMS[:no_initiative] }
    end

    def nationalities
      Nationality.where(name: nationality_name)
    end

    def nationality_name
      ApplyApi::CodeSets::Nationalities::MAPPING[hesa_trainee[:nationality]]
    end

    def training_route
      Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_trainee[:training_route]]
    end

    def ethnic_background
      Hesa::CodeSets::Ethnicities::MAPPING[hesa_trainee[:ethnic_background]]
    end

    def disability
      Hesa::CodeSets::Disabilities::MAPPING[hesa_trainee[:disability]]
    end

    def training_initiative
      Hesa::CodeSets::TrainingInitiatives::MAPPING[hesa_trainee[:training_initiative]]
    end

    def course_subject_name(subject_code)
      Hesa::CodeSets::CourseSubjects::MAPPING[subject_code]
    end

    def course_subject_one_name
      course_subject_name(hesa_trainee[:course_subject_one])
    end

    def course_education_phase
      return if course_subject_one_name.blank?

      return COURSE_EDUCATION_PHASE_ENUMS[:primary] if [
        CourseSubjects::PRIMARY_TEACHING,
        CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS,
      ].include?(course_subject_one_name)

      COURSE_EDUCATION_PHASE_ENUMS[:secondary]
    end

    def funding_entity_id
      Hesa::CodeSets::BursaryLevels::MAPPING[hesa_trainee[:bursary_level]]
    end

    # This field indicates the mode the student was reported on for the DfE census in their first year.
    def study_mode
      Hesa::CodeSets::StudyModes::MAPPING[hesa_trainee[:study_mode]]
    end

    # This field indicates the method by which a student is being taught their course.
    def mode
      @mode ||= Hesa::CodeSets::Modes::MAPPING[hesa_trainee[:mode]]
    end

    def age_range
      @age_range ||= Hesa::CodeSets::AgeRanges::MAPPING[hesa_trainee[:course_age_range]]
    end

    def reason_for_leaving
      @reason_for_leaving ||= Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_trainee[:reason_for_leaving]]
    end

    def create_degrees!
      ::Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_trainee[:degrees])
    end
  end
end
