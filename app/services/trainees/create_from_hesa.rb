# frozen_string_literal: true

module Trainees
  class CreateFromHesa
    include ServicePattern
    include DiversityAttributes

    USERNAME = "HESA"

    TRN_REGEX = /^(\d{6,7})$/.freeze

    class HesaImportError < StandardError; end

    def initialize(student_node:)
      @hesa_trainee = Hesa::Parsers::IttRecord.to_attributes(student_node: student_node)
      @trainee = Trainee.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
    end

    def call
      Audited.audit_class.as_user(USERNAME) do
        trainee.assign_attributes(mapped_attributes)
        Trainees::SetAcademicCycles.call(trainee: trainee)

        if trainee.save!
          create_degrees!
          store_hesa_metadata!
          add_multiple_disability_text!
          enqueue_background_jobs!
        end
      end
    rescue ActiveRecord::RecordInvalid
      raise(HesaImportError,
            "HESA import failed (errors: #{trainee.errors.full_messages}), (ukprn: #{hesa_trainee[:ukprn]})")
    end

  private

    attr_reader :hesa_trainee, :trainee

    def mapped_attributes
      {
        trainee_id: hesa_trainee[:trainee_id],
        training_route: training_route,
        trn: trn,
        state: trainee_state,
        hesa_updated_at: hesa_trainee[:hesa_updated_at],
        course_allocation_subject: course_allocation_subject,
      }.merge(created_from_hesa_attribute)
       .merge(personal_details_attributes)
       .merge(provider_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(withdrawal_attributes)
       .merge(deferral_attributes)
       .merge(funding_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
       .compact
    end

    def trn
      hesa_trainee[:trn] if TRN_REGEX.match?(hesa_trainee[:trn])
    end

    def created_from_hesa_attribute
      return {} if trainee.id.present?

      { created_from_hesa: true }
    end

    def personal_details_attributes
      {
        first_names: hesa_trainee[:first_names],
        last_name: hesa_trainee[:last_name],
        date_of_birth: hesa_trainee[:date_of_birth],
        gender: sex,
        nationalities: nationalities,
        email: hesa_trainee[:email],
      }
    end

    def provider_attributes
      provider = Provider.find_by(ukprn: hesa_trainee[:ukprn])
      provider ? { provider: provider } : {}
    end

    def course_attributes
      attributes = {
        course_education_phase: course_education_phase,
        course_subject_one: course_subject_one_name,
        course_subject_two: course_subject_two_name,
        course_subject_three: course_subject_three_name,
        course_min_age: age_range && age_range[0],
        course_max_age: course_max_age,
        study_mode: study_mode,
        itt_start_date: hesa_trainee[:itt_start_date],
        itt_end_date: hesa_trainee[:itt_end_date],
        commencement_date: hesa_trainee[:commencement_date] || hesa_trainee[:itt_start_date],
      }

      primary_education_phase? ? fix_invalid_primary_course_subjects(attributes) : attributes
    end

    def withdrawal_attributes
      return {} unless trainee_state == :withdrawn

      { withdraw_date: hesa_trainee[:end_date], withdraw_reason: reason_for_leaving }
    end

    def deferral_attributes
      return {} unless trainee_state == :deferred

      { defer_date: hesa_trainee[:end_date] }
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

    def funding_attributes
      MapFundingFromDttpEntityId.call(funding_entity_id: funding_entity_id)
    end

    def ethnicity_attributes
      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

        return {
          ethnic_group: ethnic_group,
          ethnic_background: ethnic_background,
        }
      end

      {
        ethnic_group: Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        ethnic_background: Diversities::NOT_PROVIDED,
      }
    end

    def sex
      Hesa::CodeSets::Sexes::MAPPING[hesa_trainee[:sex]]
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
      Hesa::CodeSets::Disabilities::MAPPING[hesa_trainee[:disability1]]
    end

    def enqueue_background_jobs!
      if FeatureService.enabled?(:integrate_with_dqt) && trainee.trn.blank?
        Dqt::RegisterForTrnJob.perform_later(trainee)
      end
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

    def course_subject_two_name
      course_subject_name(hesa_trainee[:course_subject_two])
    end

    def course_subject_three_name
      course_subject_name(hesa_trainee[:course_subject_three])
    end

    def course_max_age
      age_range && age_range[1]
    end

    def primary_education_phase?
      course_max_age && course_max_age <= AgeRange::UPPER_BOUND_PRIMARY_AGE
    end

    def course_education_phase
      return COURSE_EDUCATION_PHASE_ENUMS[:primary] if primary_education_phase?

      COURSE_EDUCATION_PHASE_ENUMS[:secondary]
    end

    def funding_entity_id
      Hesa::CodeSets::BursaryLevels::MAPPING[hesa_trainee[:bursary_level]]
    end

    # This field indicates the mode the student was reported on for the DfE census in their first year.
    def study_mode
      Hesa::CodeSets::StudyModes::MAPPING[hesa_trainee[:mode]]
    end

    def age_range
      Hesa::CodeSets::AgeRanges::MAPPING[hesa_trainee[:course_age_range]]
    end

    def reason_for_leaving
      Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_trainee[:reason_for_leaving]]
    end

    def create_degrees!
      ::Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_trainee[:degrees])
    end

    def fix_invalid_primary_course_subjects(course_attributes)
      # This always ensures "primary teaching" is the first subject or inserts it if it's missing
      other_subjects = course_subjects - [CourseSubjects::PRIMARY_TEACHING]
      course_attributes.merge(course_subject_one: CourseSubjects::PRIMARY_TEACHING,
                              course_subject_two: other_subjects.first,
                              course_subject_three: other_subjects.second)
    end

    def course_subjects
      [course_subject_one_name, course_subject_two_name, course_subject_three_name].compact
    end

    def store_hesa_metadata!
      hesa_metadatum = Hesa::Metadatum.find_or_initialize_by(trainee: trainee)
      hesa_metadatum.assign_attributes(itt_aim: itt_aim,
                                       itt_qualification_aim: itt_qualification_aim,
                                       fundability: fundability,
                                       course_programme_title: hesa_trainee[:course_programme_title]&.strip,
                                       placement_school_urn: hesa_trainee[:placements]&.first&.fetch(:school_urn),
                                       pg_apprenticeship_start_date: hesa_trainee[:pg_apprenticeship_start_date],
                                       year_of_course: hesa_trainee[:year_of_course])
      hesa_metadatum.save
    end

    def itt_aim
      Hesa::CodeSets::IttAims::MAPPING[hesa_trainee[:itt_aim]]
    end

    def itt_qualification_aim
      Hesa::CodeSets::IttQualificationAims::MAPPING[hesa_trainee[:itt_qualification_aim]]
    end

    def fundability
      Hesa::CodeSets::FundCodes::MAPPING[hesa_trainee[:fund_code]]
    end

    def trainee_state
      @trainee_state ||= MapStateFromHesa.call(hesa_trainee: hesa_trainee, trainee_persisted: trainee.persisted?) || trainee.state
    end

    def course_allocation_subject
      SubjectSpecialism.find_by(name: course_subject_one_name)&.allocation_subject
    end
  end
end
