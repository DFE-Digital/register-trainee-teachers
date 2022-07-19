# frozen_string_literal: true

module Dqt
  module Params
    class TrnRequest
      UNITED_KINGDOM = "United Kingdom"
      UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED = "United Kingdom, not otherwise specified"

      GENDER_CODES = {
        male: "Male",
        female: "Female",
        other: "Other",
        gender_not_provided: "NotProvided",
        gender_not_available: "NotAvailable",
      }.freeze

      PROGRAMME_TYPE = {
        TRAINING_ROUTE_ENUMS[:assessment_only] => "AssessmentOnlyRoute",
        TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => "EYITTAssessmentOnly",
        TRAINING_ROUTE_ENUMS[:early_years_postgrad] => "EYITTGraduateEntry",
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => "EYITTGraduateEmploymentBased",
        TRAINING_ROUTE_ENUMS[:early_years_undergrad] => "EYITTUndergraduate",
        TRAINING_ROUTE_ENUMS[:hpitt_postgrad] => "TeachFirstProgramme",
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => "UndergraduateOptIn",
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => "Apprenticeship",
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => "Core",
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => "Core",
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => "SchoolDirectTrainingProgrammeSalaried",
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => "SchoolDirectTrainingProgrammeSelfFunded",
      }.freeze

      DEGREE_CLASSES = {
        Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS => "FirstClassHonours",
        Dttp::CodeSets::Grades::UPPER_SECOND_CLASS_HONOURS => "UpperSecondClassHonours",
        Dttp::CodeSets::Grades::LOWER_SECOND_CLASS_HONOURS => "LowerSecondClassHonours",
        Dttp::CodeSets::Grades::THIRD_CLASS_HONOURS => "ThirdClassHonours",
        Dttp::CodeSets::Grades::OTHER => "NotKnown",
        Dttp::CodeSets::Grades::PASS => "Pass",
      }.freeze

      attr_reader :params

      def initialize(trainee:)
        @trainee = trainee
        @degree = trainee.degrees.first
        @params = build_params
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_params
        {
          "firstName" => trainee.first_names,
          "middleName" => trainee.middle_names,
          "lastName" => trainee.last_name,
          "birthDate" => trainee.date_of_birth.iso8601,
          "emailAddress" => trainee.email,
          "address" => address_params,
          "husid" => trainee.hesa_id,
          "genderCode" => GENDER_CODES[trainee.gender.to_sym],
          "initialTeacherTraining" => initial_teacher_training_params,
          "qualification" => qualification_params,
        }.compact
      end

      def address_params
        trainee.uk? ? uk_address : non_uk_address
      end

      def uk_address
        {

          "addressLine1" => trainee.address_line_one,
          "addressLine2" => trainee.address_line_two,
          "addressLine3" => nil,
          "city" => trainee.town_city,
          "postalCode" => trainee.postcode,
          "country" => UNITED_KINGDOM,
        }
      end

      def non_uk_address
        {
          "addressLine1" => trainee.international_address,
        }
      end

      def initial_teacher_training_params
        {
          "providerUkprn" => trainee.provider.ukprn,
          "programmeStartDate" => trainee.itt_start_date.iso8601,
          "programmeEndDate" => trainee.itt_end_date.iso8601,
          "programmeType" => PROGRAMME_TYPE[trainee.training_route],
          "subject1" => course_subject_code(trainee.course_subject_one),
          "subject2" => course_subject_code(trainee.course_subject_two),
          "subject3" => course_subject_code(trainee.course_subject_three),
          "ageRangeFrom" => trainee.course_min_age,
          "ageRangeTo" => trainee.course_max_age,
        }
      end

      def qualification_params
        return if trainee.degrees.empty?

        {
          "providerUkprn" => institution_ukprn,
          "countryCode" => country_code,
          "subject" => subject_code,
          "class" => DEGREE_CLASSES[degree.grade],
          "date" => Date.parse("01-01-#{degree.graduation_year}").iso8601,
        }
      end

      def course_subject_code(subject_name)
        # these three subjects are not coded by HESA so we've agreed these encodings with the DQT team
        return "999001" if subject_name == ::CourseSubjects::CITIZENSHIP
        return "999002" if subject_name == ::CourseSubjects::PHYSICAL_EDUCATION
        return "999003" if subject_name == ::CourseSubjects::DESIGN_AND_TECHNOLOGY

        Hesa::CodeSets::CourseSubjects::MAPPING.invert[subject_name]
      end

      def subject_code
        DfE::ReferenceData::Degrees::SUBJECTS.some({ name: degree.subject }).first&.hecos_code
      end

      def institution_ukprn
        return nil if degree.institution_uuid.nil?

        DfE::ReferenceData::Degrees::INSTITUTIONS.one(degree.institution_uuid)[:ukprn]
      end

      def country_code
        country = degree.uk? ? UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED : degree.country
        Hesa::CodeSets::Countries::MAPPING.find { |_, name| name.start_with?(country) }&.first
      end

      attr_reader :trainee, :degree
    end
  end
end
