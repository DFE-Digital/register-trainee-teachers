# frozen_string_literal: true

module Api
  module MapHesaAttributes
    class V01
      include ServicePattern
      include HasDiversityAttributes
      include HasCourseAttributes

      ATTRIBUTES = %i[
        nationality
        ethnic_group
        ethnic_background
        employing_school_urn
        lead_school_urn
      ].freeze

      NOT_APPLICABLE_SCHOOL_URNS = %w[900000 900010 900020 900030].freeze
      VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL = "C"
      DISABILITY_PARAM_REGEX = /\Adisability\d+\z/

      def self.disability_attributes(params)
        params[:data].keys.select { |key| key.to_s.match(DISABILITY_PARAM_REGEX) }
      end

      def initialize(trainee: nil, params:)
        @trainee = trainee
        @params  = params
      end

      def call
        mapped_params
      end

    private

      attr_reader :trainee, :params

      delegate :ethnic_background, to: :trainee, prefix: true, allow_nil: true

      def mapped_params
        additional_params = params.except(*ATTRIBUTES)

        additional_params.merge({
          sex:,
          training_route:,
          nationalisations_attributes:,
          degrees_attributes:,
          placements_attributes:,
          hesa_disabilities:,
          course_study_mode:,
        })
        .merge(course_attributes)
        .merge(ethnicity_and_disability_attributes)
        .merge(funding_attributes)
        .merge(training_initiative_attributes)
        .merge(school_attributes)
        .compact
      end

      def degrees_attributes
        params[:degrees_attributes]&.map { |degree| Api::MapHesaAttributes::Degrees::V01.new(degree).call }
      end

      def placements_attributes
        params[:placements_attributes]&.map { |placement| Api::MapHesaAttributes::Placements::V01.new(placement).call }
      end

      def sex
        ::Hesa::CodeSets::Sexes::MAPPING[params[:sex]] || params[:sex]
      end

      def training_route
        ::Hesa::CodeSets::TrainingRoutes::MAPPING[params[:training_route]]
      end

      def nationalisations_attributes
        return [] unless nationality_name || params[:nationality]

        [{ name: nationality_name || params[:nationality] }]
      end

      def nationality_name
        RecruitsApi::CodeSets::Nationalities::MAPPING[params[:nationality]]
      end

      def ethnic_background
        ::Hesa::CodeSets::Ethnicities::MAPPING[params[:ethnicity]] ||
          trainee_ethnic_background
      end

      def hesa_disabilities
        params.select { |k, _v| k.to_s.match(DISABILITY_PARAM_REGEX) }
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

      def itt_qualification_aim
        ::Hesa::CodeSets::IttQualificationAims::MAPPING[params[:itt_qualification_aim]]
      end

      def fundability
        ::Hesa::CodeSets::FundCodes::MAPPING[params[:fund_code]]
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

      def course_max_age
        params[:course_max_age]
      end

      def course_study_mode
        params[:study_mode]
      end

      def course_attributes
        attributes = super

        attributes[:course_allocation_subject_id] = attributes.delete(:course_allocation_subject)&.id

        attributes
      end

      def funding_attributes
        ::Trainees::MapFundingFromDttpEntityId.call(funding_entity_id:)
      end

      def funding_entity_id
        ::Hesa::CodeSets::BursaryLevels::MAPPING[params[:funding_method]]
      end

      def school_attributes
        attrs = {}

        return attrs if params[:lead_school_urn].blank?

        if NOT_APPLICABLE_SCHOOL_URNS.include?(params[:lead_school_urn])
          attrs.merge!(lead_school_not_applicable: true)
        else
          lead_school_id = School.find_by(urn: params[:lead_school_urn], lead_school: true)&.id

          attrs.merge!(
            lead_school_id: lead_school_id,
            lead_school_not_applicable: lead_school_id.nil?,
          )
        end

        if params[:employing_school_urn].present?
          if NOT_APPLICABLE_SCHOOL_URNS.include?(params[:employing_school_urn])
            attrs.merge!(employing_school_not_applicable: true)
          else
            employing_school_id = School.find_by(urn: params[:employing_school_urn], lead_school: false)&.id

            attrs.merge!(
              employing_school_id: employing_school_id,
              employing_school_not_applicable: employing_school_id.nil?,
            )
          end
        end

        attrs
      end

      def training_initiative_attributes
        { training_initiative: training_initiative || ROUTE_INITIATIVES_ENUMS[:no_initiative] }
      end

      def training_initiative
        return ROUTE_INITIATIVES_ENUMS[:veterans_teaching_undergraduate_bursary] if veteran_teaching_undergraduate_bursary?

        ::Hesa::CodeSets::TrainingInitiatives::MAPPING[params[:training_initiative]]
      end

      def veteran_teaching_undergraduate_bursary?
        params[:bursary_level] == VETERAN_TEACHING_UNDERGRADUATE_BURSARY_LEVEL
      end
    end
  end
end
