# frozen_string_literal: true

module Trainees
  class CreateFromHesa
    include ServicePattern
    include HasDiversityAttributes
    include HasCourseAttributes

    USERNAME = "HESA"

    NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010 900020 900030].freeze

    VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL = "C"

    MIN_NUMBER_OF_DAYS_SUGGESTING_COURSE_CHANGE = 30

    class HesaImportError < StandardError; end

    def initialize(hesa_trainee:, record_source:)
      @hesa_trainee = hesa_trainee
      @trainee = find_or_initialize_trainee_by(hesa_id: hesa_trainee[:hesa_id])
      @record_source = record_source
      @current_trainee_state = @trainee&.state&.to_sym
    end

    def call
      # Skip if we have no record to take action on e.g create or update
      return if trainee.blank?

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
            "HESA import failed (errors: #{trainee.errors.full_messages}), (ukprn: #{hesa_trainee[:ukprn]}, hesa_id: #{hesa_trainee[:hesa_id]})")
    end

  private

    attr_reader :hesa_trainee, :trainee, :record_source, :current_trainee_state

    def mapped_attributes
      {
        provider_trainee_id: hesa_trainee[:provider_trainee_id],
        training_route: training_route,
        state: mapped_trainee_state,
        hesa_updated_at: hesa_trainee[:hesa_updated_at],
        record_source: trainee_record_source,
      }.compact # trainee_state can be nil, therefore we don't want to override the current state
       .merge(personal_details_attributes)
       .merge(provider_attributes)
       .merge(ethnicity_and_disability_attributes)
       .merge(course_attributes)
       .merge(submitted_for_trn_attributes)
       .merge(funding_attributes)
       .merge(school_attributes)
       .merge(training_initiative_attributes)
       .merge(apply_attributes)
    end

    def find_or_initialize_trainee_by(hesa_id:)
      # If we have multiple trainees with the same HESA ID, we want to pick the one most recently created
      trainee = Trainee.where(hesa_id:).order(:created_at).last

      return new_trainee_record(hesa_id) if trainee.blank?
      # if the trainee is neither awarded nor withdrawn we always update the existing record
      return trainee unless awarded_or_withdrawn?(trainee)

      # if the trainee is either awarded or withdrawn and the ITT start date is different to the existing record,
      # we need to create a new record because the provider is submitting the trainee for a new course
      new_trainee_record(hesa_id) if itt_start_date_significantly_changed_for?(trainee)

      # if the trainee's ITT start date has not changed, and the trainee is either awarded or withdrawn,
      # then we do nothing (we don't create a new record, nor update the existing one), therefore we
      # return no record at all so the importer knows to skip this case completely
    end

    # As soon as the trainee has been submitted over the HESA collection
    # endpoint, the record_source should remain as "HESA collection". Only
    # trainees who have ONLY ever been submitted over the TRN data endpoint
    # should have the record_source "HESA TRN data"
    def trainee_record_source
      if record_source == Trainee::HESA_TRN_DATA_SOURCE && trainee.hesa_collection_record?
        return Trainee::HESA_COLLECTION_SOURCE
      end

      record_source
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

    def submitted_for_trn_attributes
      { submitted_for_trn_at: Time.zone.now }
    end

    def school_attributes
      attrs = {}

      return attrs if hesa_trainee[:lead_partner_urn].blank?

      if NOT_APPLICABLE_SCHOOL_URNS.include?(hesa_trainee[:lead_partner_urn])
        attrs.merge!(lead_partner_not_applicable: true)
      else
        attrs.merge!(lead_school: School.find_by(urn: hesa_trainee[:lead_partner_urn]), lead_partner_not_applicable: false)
      end

      if hesa_trainee[:employing_school_urn].present?
        if NOT_APPLICABLE_SCHOOL_URNS.include?(hesa_trainee[:employing_school_urn])
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

    def apply_attributes
      { application_choice_id: hesa_trainee[:application_choice_id] }
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
      RecruitsApi::CodeSets::Nationalities::MAPPING[hesa_trainee[:nationality]]
    end

    def training_route
      ::Hesa::CodeSets::TrainingRoutes::MAPPING[hesa_trainee[:training_route]]
    end

    def ethnic_background
      ::Hesa::CodeSets::Ethnicities::MAPPING[hesa_trainee[:ethnic_background]]
    end

    def disabilities
      (1..9).map do |n|
        ::Hesa::CodeSets::Disabilities::MAPPING[hesa_trainee[:"disability#{n}"]]
      end.compact
    end

    def enqueue_background_jobs!
      return unless FeatureService.enabled?(:integrate_with_dqt)

      if trainee.trn.present?
        Trainees::Update.call(trainee:)
      else
        Dqt::RegisterForTrnJob.perform_later(trainee)
      end
    end

    def training_initiative
      return ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] if veteran_teaching_undergraduate_bursary?

      ::Hesa::CodeSets::TrainingInitiatives::MAPPING[hesa_trainee[:training_initiative]]
    end

    def veteran_teaching_undergraduate_bursary?
      hesa_trainee[:bursary_level] == VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL
    end

    def itt_start_date
      hesa_trainee[:itt_start_date]
    end

    def itt_end_date
      hesa_trainee[:itt_end_date]
    end

    def trainee_start_date
      hesa_trainee[:trainee_start_date].presence || itt_start_date
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
      DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[hesa_trainee[:course_age_range]]
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

    def new_trainee_record(hesa_id)
      Trainee.new(hesa_id:)
    end

    def itt_start_date_significantly_changed_for?(trainee)
      (trainee.itt_start_date - Date.parse(itt_start_date)).abs > MIN_NUMBER_OF_DAYS_SUGGESTING_COURSE_CHANGE
    end

    def awarded_or_withdrawn?(trainee)
      %i[awarded withdrawn].include?(trainee.state.to_sym)
    end
  end
end
