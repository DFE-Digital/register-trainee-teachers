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
          sex: sex,
          training_route: training_route,
          nationalisations_attributes: nationalisations_attributes,
        })
        .merge(course_attributes)
        .merge(ethnicity_and_disability_attributes)
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
    end
  end
end
