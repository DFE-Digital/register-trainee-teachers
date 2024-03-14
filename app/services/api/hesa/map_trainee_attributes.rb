# frozen_string_literal: true

module Api
  module Hesa
    class MapTraineeAttributes
      include ServicePattern
      include HasDiversityAttributes
      include HasCourseAttributes

      ATTRIBUTES = %i[
        first_names
        last_name
        email
        date_of_birth
        ethnic_background
        sex
        course_subject_one
        course_subject_two
        course_subject_three
        itt_end_date
        study_mode
        training_route
        nationality
        itt_start_date
        trainee_start_date
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
        {
          first_names: params[:first_names],
          last_name: params[:last_name],
          date_of_birth: params[:date_of_birth],
          email: params[:email],
          sex: sex,
          training_route: training_route,
          nationalities: nationalities,
        }
        .merge(course_attributes)
        .merge(ethnicity_and_disability_attributes)
      end

      def sex
        ::Hesa::CodeSets::Sexes::MAPPING[params[:sex]]
      end

      def training_route
        ::Hesa::CodeSets::TrainingRoutes::MAPPING[params[:training_route]]
      end

      def nationalities
        Nationality.where(name: nationality_name)
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
