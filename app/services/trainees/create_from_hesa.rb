# frozen_string_literal: true

module Trainees
  class CreateFromHesa
    include ServicePattern
    include HasDiversityAttributes
    include HasCourseAttributes

    USERNAME = "HESA"

    NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010].freeze

    class HesaImportError < StandardError; end

    def initialize(student_node:, record_source:)
      @hesa_trainee = ::Hesa::Parsers::IttRecord.to_attributes(student_node:)
      @trainee = Trainee.find_or_initialize_by(hesa_id: hesa_trainee[:hesa_id])
      @record_source = record_source
      @current_trainee_state = @trainee.state.to_sym
    end

    def call
      return if @current_trainee_state == :awarded

      Audited.audit_class.as_user(USERNAME) do
        trainee.assign_attributes(mapped_attributes)

        if trainee.save!
          create_degrees!
          create_placements!
          store_hesa_metadata!
          enqueue_background_jobs!
          check_for_missing_hesa_mappings!
        end
      end
    rescue ActiveRecord::RecordInvalid
      raise(HesaImportError,
            "HESA import failed (errors: #{trainee.errors.full_messages}), (ukprn: #{hesa_trainee[:ukprn]})")
    end

  private

    attr_reader :hesa_trainee, :trainee, :record_source, :current_trainee_state

    def mapped_attributes
      {
        trainee_id: hesa_trainee[:trainee_id],
        training_route: training_route,
        state: mapped_trainee_state,
        hesa_updated_at: hesa_trainee[:hesa_updated_at],
        record_source: trainee_record_source,
      }.compact # trainee_state can be nil, therefore we don't want to override the current state
       .merge(created_from_hesa_attribute)
       .merge(personal_details_attributes)
       .merge(provider_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(withdrawal_attributes)
       .merge(deferral_attributes)
       .merge(submitted_for_trn_attributes)
       .merge(funding_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
    end

    # As soon as the trainee has been submitted over the HESA collection
    # endpoint, the record_source should remain as "HESA collection". Only
    # trainees who have ONLY ever been submitted over the TRN data endpoint
    # should have the record_source "HESA TRN data"
    def trainee_record_source
      if record_source == RecordSources::HESA_TRN_DATA && trainee.record_source == RecordSources::HESA_COLLECTION
        return RecordSources::HESA_COLLECTION
      end

      record_source
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
        sex: sex,
        nationalities: nationalities,
        email: hesa_trainee[:email],
      }
    end

    def provider_attributes
      provider = Provider.find_by(ukprn: hesa_trainee[:ukprn])
      provider ? { provider: } : {}
    end

    def withdrawal_attributes
      return { withdraw_date: nil, withdraw_reason: nil } unless mapped_trainee_state == :withdrawn

      { withdraw_date: hesa_trainee[:end_date], withdraw_reason: reason_for_leaving }
    end

    def deferral_attributes
      return { defer_date: nil } unless mapped_trainee_state == :deferred

      { defer_date: hesa_trainee[:end_date] }
    end

    def submitted_for_trn_attributes
      return {} unless request_for_trn?

      { submitted_for_trn_at: Time.zone.now }
    end

    def school_attributes
      attrs = {}

      return attrs if hesa_trainee[:lead_school_urn].blank?

      if NOT_APPLICABLE_SCHOOL_URNS.include?(hesa_trainee[:lead_school_urn])
        attrs.merge!(lead_school_not_applicable: true)
      else
        attrs.merge!(lead_school: School.find_by(urn: hesa_trainee[:lead_school_urn]))
      end

      if hesa_trainee[:employing_school_urn].present?
        if NOT_APPLICABLE_SCHOOL_URNS.include?(hesa_trainee[:lead_school_urn])
          attrs.merge!(employing_school_not_applicable: true)
        else
          attrs.merge!(employing_school: School.find_by(urn: hesa_trainee[:employing_school_urn]))
        end
      end

      attrs
    end

    def training_initiative_attributes
      { training_initiative: training_initiative || ROUTE_INITIATIVES_ENUMS[:no_initiative] }
    end

    def funding_attributes
      MapFundingFromDttpEntityId.call(funding_entity_id:)
    end

    def sex
      ::Hesa::CodeSets::Sexes::MAPPING[hesa_trainee[:sex]]
    end

    def nationalities
      Nationality.where(name: nationality_name)
    end

    def nationality_name
      ApplyApi::CodeSets::Nationalities::MAPPING[hesa_trainee[:nationality]]
    end

    def training_route
      ::Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_trainee[:training_route]]
    end

    def ethnic_background
      ::Hesa::CodeSets::Ethnicities::MAPPING[hesa_trainee[:ethnic_background]]
    end

    def disabilities
      (1..9).map do |n|
        ::Hesa::CodeSets::Disabilities::MAPPING[hesa_trainee["disability#{n}".to_sym]]
      end.compact
    end

    def enqueue_background_jobs!
      return unless FeatureService.enabled?(:integrate_with_dqt)

      if request_for_trn?
        Dqt::RegisterForTrnJob.perform_later(trainee)
      else
        Trainees::Update.call(trainee:)
      end

      Dqt::WithdrawTraineeJob.perform_later(trainee) if enqueue_dqt_withdrawal_job?
    end

    def enqueue_dqt_withdrawal_job?
      current_trainee_state != :withdrawn && mapped_trainee_state == :withdrawn
    end

    def request_for_trn?
      # Withdrawn trainees are also expected to get a TRN
      trainee.trn.blank? && (mapped_trainee_state == :submitted_for_trn || mapped_trainee_state == :withdrawn)
    end

    def training_initiative
      ::Hesa::CodeSets::TrainingInitiatives::MAPPING[hesa_trainee[:training_initiative]]
    end

    # Use HESA's itt_commencement_date first, this is populated when the trainee
    # has transferred from a non-QTS  awarding course, to an ITT (QTS awarding)
    # course, otherwise use HESA's commencement_date.  This is the start date
    # for trainees who have not transferred courses.
    def itt_start_date
      hesa_trainee[:itt_commencement_date].presence || hesa_trainee[:commencement_date]
    end

    def itt_end_date
      hesa_trainee[:itt_end_date]
    end

    # HESA do not distinguish between the ITT start date and the trainee
    # start date, so we're setting both to the ITT start date.
    def trainee_start_date
      itt_start_date
    end

    def course_subject_name(subject_code)
      ::Hesa::CodeSets::CourseSubjects::MAPPING[subject_code]
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

    def course_education_phase
      return COURSE_EDUCATION_PHASE_ENUMS[:primary] if primary_education_phase?

      COURSE_EDUCATION_PHASE_ENUMS[:secondary]
    end

    def funding_entity_id
      ::Hesa::CodeSets::BursaryLevels::MAPPING[hesa_trainee[:bursary_level]]
    end

    # This field indicates the mode the student was reported on for the DfE census in their first year.
    def study_mode
      ::Hesa::CodeSets::StudyModes::MAPPING[hesa_trainee[:mode]]
    end

    def course_age_range
      ::Hesa::CodeSets::AgeRanges::MAPPING[hesa_trainee[:course_age_range]]
    end

    def reason_for_leaving
      ::Hesa::CodeSets::ReasonsForLeavingCourse::MAPPING[hesa_trainee[:reason_for_leaving]]
    end

    def create_degrees!
      ::Degrees::CreateFromHesa.call(trainee: trainee, hesa_degrees: hesa_trainee[:degrees])
    end

    def create_placements!
      ::Placements::CreateFromHesa.call(trainee: trainee, hesa_placements: hesa_trainee[:placements])
    end

    def store_hesa_metadata!
      hesa_metadatum = ::Hesa::Metadatum.find_or_initialize_by(trainee:)
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
      ::Hesa::CodeSets::IttAims::MAPPING[hesa_trainee[:itt_aim]]
    end

    def itt_qualification_aim
      ::Hesa::CodeSets::IttQualificationAims::MAPPING[hesa_trainee[:itt_qualification_aim]]
    end

    def fundability
      ::Hesa::CodeSets::FundCodes::MAPPING[hesa_trainee[:fund_code]]
    end

    def mapped_trainee_state
      @mapped_trainee_state ||= MapStateFromHesa.call(hesa_trainee:, trainee:) || trainee.state
    end

    def check_for_missing_hesa_mappings!
      ::Hesa::ValidateMapping.call(hesa_trainee:, record_source:)
    end
  end
end
