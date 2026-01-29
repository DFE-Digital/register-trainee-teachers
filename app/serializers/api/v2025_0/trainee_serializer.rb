# frozen_string_literal: true

module Api
  module V20250
    class TraineeSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        iqts_country
        additional_dttp_data
        course_uuid
        commencement_status
        created_from_dttp
        created_from_hesa
        discarded_at
        hesa_updated_at
        hesa_editable
        slug
        slug_sent_to_trs_at
        state
        searchable
        submission_ready
        progress
        provider_id
        dttp_id
        placement_assignment_dttp_id
        placement_detail
        dttp_update_sha
        dormancy_dttp_id
        training_partner_id
        training_partner_not_applicable
        employing_school_id
        employing_school_not_applicable
        course_allocation_subject_id
        start_academic_cycle_id
        end_academic_cycle_id
        ebacc
        region
        hesa_trn_submission_id
        application_choice_id
        apply_application_id
        applying_for_bursary
        applying_for_grant
        applying_for_scholarship
        bursary_tier
      ].freeze

      def initialize(trainee)
        @trainee = trainee
      end

      def as_hash
        @trainee.attributes
          .except(*EXCLUDED_ATTRIBUTES)
          .with_indifferent_access.merge(
            provider_attributes,
            diversity_attributes,
            course_attributes,
            lead_partner_and_employing_school_attributes,
            hesa_trainee_attributes,
            sex: sex,
            study_mode: course_study_mode,
            course_subject_one: course_subject_one,
            course_subject_two: course_subject_two,
            course_subject_three: course_subject_three,
            training_route: training_route,
            nationality: nationality,
            training_initiative: training_initiative,
            withdraw_date: @trainee.current_withdrawal&.date&.iso8601,
            withdraw_reasons: withdraw_reasons,
            withdrawal_trigger: @trainee.current_withdrawal&.trigger,
            withdrawal_future_interest: @trainee.current_withdrawal&.future_interest,
            withdrawal_another_reason: @trainee.current_withdrawal&.another_reason,
            withdrawal_safeguarding_concern_reasons: @trainee.current_withdrawal&.safeguarding_concern_reasons,
            placements: placements,
            degrees: degrees,
            state: @trainee.state,
            trainee_id: @trainee.slug,
            recommended_for_award_at: recommended_for_award_at,
            application_id: @trainee.application_choice_id,
          )
      end

      def degrees
        @degrees ||= @trainee.degrees.map do |degree|
          DegreeSerializer.new(degree).as_hash
        end
      end

      def placements
        @placements ||= @trainee.placements.includes(:school).map do |placement|
          PlacementSerializer.new(placement).as_hash
        end
      end

      def provider_attributes
        {
          ukprn: @trainee.provider&.ukprn,
        }
      end

      def diversity_attributes
        attributes = {
          ethnic_group:,
          ethnicity:,
          disability_disclosure:,
        }
        assign_disabilities(attributes)

        attributes
      end

      def assign_disabilities(attributes)
        @trainee.hesa_trainee_detail&.hesa_disabilities&.each do |key, disability|
          attributes[key] = disability
        end
        attributes
      end

      def ethnicity
        Hesa::CodeSets::Ethnicities::MAPPING.key(@trainee.ethnic_background)
      end

      def course_attributes
        {
          course_qualification:,
          course_title:,
          course_level:,
          course_education_phase:,
          course_itt_start_date:,
          course_age_range:,
          trainee_start_date:,
        }
      end

      def course_qualification
        @trainee.award_type
      end

      def course_level
        @trainee.undergrad_route? ? "undergrad" : "postgrad"
      end

      def course_title
        @trainee.published_course&.name
      end

      def course_subject_one
        ::Hesa::CodeSets::CourseSubjects::MAPPING.key(@trainee.course_subject_one)
      end

      def course_subject_two
        ::Hesa::CodeSets::CourseSubjects::MAPPING.key(@trainee.course_subject_two)
      end

      def course_subject_three
        ::Hesa::CodeSets::CourseSubjects::MAPPING.key(@trainee.course_subject_three)
      end

      def course_study_mode
        @trainee&.hesa_trainee_detail&.course_study_mode
      end

      def course_itt_start_date
        @trainee.itt_start_date&.iso8601
      end

      def course_age_range
        @trainee&.hesa_trainee_detail&.course_age_range
      end

      def recommended_for_award_at
        @trainee.recommended_for_award_at&.iso8601
      end

      def lead_partner_and_employing_school_attributes
        {
          employing_school_urn:,
          lead_partner_ukprn:,
          lead_partner_urn:,
        }
      end

      def employing_school_urn
        @trainee.employing_school&.urn
      end

      def lead_partner_ukprn
        @trainee.training_partner&.ukprn
      end

      def lead_partner_urn
        @trainee.training_partner&.urn
      end

      def hesa_trainee_attributes
        return {} unless @trainee.hesa_trainee_detail

        HesaTraineeDetailSerializer.new(@trainee.hesa_trainee_detail).as_hash
      end

      def nationality
        return if @trainee.nationalities.reload.blank?

        RecruitsApi::CodeSets::Nationalities::APPLY_MAPPING[
          @trainee.nationalities.first.name,
        ]
      end

      def training_route
        ::Hesa::CodeSets::TrainingRoutes::MAPPING.key(@trainee.training_route)
      end

      def training_initiative
        ::Hesa::CodeSets::TrainingInitiatives::MAPPING.key(@trainee.training_initiative)
      end

      def sex
        ::Hesa::CodeSets::Sexes::MAPPING.key(::Trainee.sexes[@trainee.sex])
      end

      def withdraw_reasons
        @trainee.current_withdrawal_reasons&.map(&:name)
      end

      delegate :ethnic_group, :disability_disclosure, :course_education_phase, :trainee_start_date, to: :@trainee
    end
  end
end
