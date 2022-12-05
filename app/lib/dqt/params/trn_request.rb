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
        prefer_not_to_say: "NotProvided",
        sex_not_provided: "NotAvailable",
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
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => "ProviderLedPostgrad",
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => "ProviderLedUndergrad",
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => "SchoolDirectTrainingProgrammeSalaried",
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => "SchoolDirectTrainingProgramme",
      }.freeze

      DEGREE_CLASSES = {
        Dttp::CodeSets::Grades::FIRST_CLASS_HONOURS => "FirstClassHonours",
        Dttp::CodeSets::Grades::UPPER_SECOND_CLASS_HONOURS => "UpperSecondClassHonours",
        Dttp::CodeSets::Grades::LOWER_SECOND_CLASS_HONOURS => "LowerSecondClassHonours",
        Dttp::CodeSets::Grades::THIRD_CLASS_HONOURS => "ThirdClassHonours",
        Dttp::CodeSets::Grades::OTHER => "NotKnown",
        Dttp::CodeSets::Grades::PASS => "Pass",
      }.freeze

      ITT_QUALIFICATION_AIMS = {
        "Professional status only" => "ProfessionalStatusOnly",
        "Both professional status and academic award" => "ProfessionalStatusAndAcademicAward",
      }.freeze

      ITT_QUALIFICATION_TYPES = {
        "BA" => "BA",
        "BA (Hons)" => "BAHons",
        "BEd" => "BEd",
        "BEd (Hons)" => "BEdHons",
        "BSc" => "BSc",
        "BSc (Hons)" => "BScHons",
        "Postgraduate Certificate in Education" => "PostgraduateCertificateInEducation",
        "Postgraduate Diploma in Education" => "PostgraduateDiplomaInEducation",
        "Undergraduate Master of Teaching" => "UndergraduateMasterOfTeaching",
        "Professional Graduate Certificate in Education" => "ProfessionalGraduateCertificateInEducation",
        "Masters, not by research" => "MastersNotByResearch",
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
          "genderCode" => GENDER_CODES[trainee.sex.to_sym],
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
          "programmeEndDate" => itt_end_date&.iso8601,
          "programmeType" => PROGRAMME_TYPE[trainee.training_route],
          "subject1" => course_subject_code(trainee.course_subject_one),
          "subject2" => course_subject_code(trainee.course_subject_two),
          "subject3" => course_subject_code(trainee.course_subject_three),
          "ageRangeFrom" => trainee.course_min_age,
          "ageRangeTo" => trainee.course_max_age,
          "ittQualificationAim" => ITT_QUALIFICATION_AIMS[trainee.hesa_metadatum&.itt_aim],
          "ittQualificationType" => ITT_QUALIFICATION_TYPES[trainee.hesa_metadatum&.itt_qualification_aim],
        }
      end

      def qualification_params
        return if degree.nil?
        return if CodeSets::DegreeTypes::FOUNDATIONS.include?(degree.uk_degree_uuid)

        {
          "providerUkprn" => institution_ukprn,
          "countryCode" => country_code,
          "subject" => subject_code,
          "class" => DEGREE_CLASSES[degree.grade],
          "date" => graduation_date,
          "heQualificationType" => CodeSets::DegreeTypes::MAPPING[degree.uk_degree_uuid],
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
        Degrees::DfEReference.find_subject(name: degree.subject)&.hecos_code
      end

      def graduation_date
        return if degree.graduation_year.nil?

        Date.parse("01-01-#{degree.graduation_year}").iso8601
      end

      def institution_ukprn
        return if degree.institution_uuid.nil?

        Degrees::DfEReference::INSTITUTIONS.one(degree.institution_uuid)&.ukprn
      end

      def country_code
        country = degree.uk? ? UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED : degree.country
        Hesa::CodeSets::Countries::MAPPING.find { |_, name| name.start_with?(country) }&.first
      end

      def itt_end_date
        trainee.itt_end_date || (start_date + estimated_course_duration)
      end

      def start_date
        trainee.trainee_start_date || trainee.itt_start_date
      end

      def estimated_course_duration
        return 70.months if trainee.provider_led_undergrad? && trainee.part_time?

        return 34.months if trainee.provider_led_undergrad? && trainee.full_time?

        return 22.months if trainee.opt_in_undergrad? || trainee.part_time?

        10.months
      end

      attr_reader :trainee, :degree
    end
  end
end
