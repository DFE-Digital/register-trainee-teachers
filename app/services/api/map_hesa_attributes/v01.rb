# frozen_string_literal: true

module Api
  module MapHesaAttributes
    class V01
      include ServicePattern
      include HasDiversityAttributes
      include HasCourseAttributes

      ATTRIBUTES = %i[
        nationality
      ].freeze

      NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010 900020 900030].freeze

      def initialize(params:)
        @params = params
      end

      def call
        mapped_params
      end

    private

      attr_reader :params

      def mapped_params
        additional_params = params.except(*ATTRIBUTES)

        additional_params.merge({
          sex:,
          training_route:,
          nationalisations_attributes:,
        })
        .merge(course_attributes)
        .merge(ethnicity_and_disability_attributes)
        .merge(provider)
        .merge(funding_attributes)
        .merge(school_attributes)
        .compact
      end

      def sex
        ::Hesa::CodeSets::Sexes::MAPPING[params[:sex]]
      end

      def training_route
        ::Hesa::CodeSets::TrainingRoutes::MAPPING[params[:training_route]]
      end

      def nationalisations_attributes
        return [] unless nationality_name

        [{ name: nationality_name }]
      end

      def nationality_name
        RecruitsApi::CodeSets::Nationalities::MAPPING[params[:nationality]]
      end

      def ethnic_background
        ::Hesa::CodeSets::Ethnicities::MAPPING[params[:ethnic_background]]
      end

      def disabilities
        (1..9).map do |n|
          ::Hesa::CodeSets::Disabilities::MAPPING[params[:"disability#{n}"]]
        end.compact
      end

      def itt_start_date
        params[:itt_start_date]
      end

      def itt_end_date
        params[:itt_end_date]
      end

      def trainee_start_date
        params[:trainee_start_date].presence || itt_start_date
      end

      def course_subject_name(subject_code)
        ::Hesa::CodeSets::CourseSubjects::MAPPING[subject_code]
      end

      def course_subject_one_name
        course_subject_name(params[:course_subject_one])
      end

      def course_subject_two_name
        course_subject_name(params[:course_subject_two])
      end

      def course_subject_three_name
        course_subject_name(params[:course_subject_three])
      end

      def course_education_phase
        return COURSE_EDUCATION_PHASE_ENUMS[:primary] if primary_education_phase?

        COURSE_EDUCATION_PHASE_ENUMS[:secondary]
      end

      def study_mode
        ::Hesa::CodeSets::StudyModes::MAPPING[params[:study_mode]]
      end

      def course_age_range
        DfE::ReferenceData::AgeRanges::HESA_CODE_SETS[params[:course_age_range]]
      end

      def course_attributes
        attributes = super

        attributes[:course_allocation_subject_id] = attributes.delete(:course_allocation_subject)&.id

        attributes
      end

      def provider
        provider = Provider.find_by(ukprn: params[:ukprn])
        provider ? { provider: } : {}
      end

      def funding_attributes
        MapFundingFromDttpEntityId.call(funding_entity_id:)
      end

      def funding_entity_id
        ::Hesa::CodeSets::BursaryLevels::MAPPING[params[:bursary_level]]
      end

      def school_attributes
        attrs = {}

        return attrs if params[:lead_school_urn].blank?

        if NOT_APPLICABLE_SCHOOL_URNS.include?(params[:lead_school_urn])
          attrs.merge!(lead_school_not_applicable: true)
        else
          attrs.merge!(lead_school: School.find_by(urn: params[:lead_school_urn]), lead_school_not_applicable: false)
        end

        if params[:employing_school_urn].present?
          if NOT_APPLICABLE_SCHOOL_URNS.include?(params[:employing_school_urn])
            attrs.merge!(employing_school_not_applicable: true)
          else
            attrs.merge!(employing_school: School.find_by(urn: params[:employing_school_urn]))
          end
        end

        attrs
      end
    end
  end
end
