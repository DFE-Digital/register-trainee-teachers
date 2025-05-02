# frozen_string_literal: true

require "dfe/reference_data/countries_and_territories"

module Dqt
  module Params
    class TrnRequest
      UNITED_KINGDOM = "United Kingdom"
      UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED = "United Kingdom, not otherwise specified"
      DQT_IQTS_PROGRAMME_TYPE = "InternationalQualifiedTeacherStatus"

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
        TRAINING_ROUTE_ENUMS[:hpitt_postgrad] => "HighPotentialITT",
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => "UndergraduateOptIn",
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => "Apprenticeship",
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => "PrimaryAndSecondaryPostgraduateFeeFunded",
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => "PrimaryAndSecondaryUndergraduateFeeFunded",
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => "SchoolDirectTrainingProgrammeSalaried",
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => "SchoolDirectTrainingProgramme",
        TRAINING_ROUTE_ENUMS[:iqts] => DQT_IQTS_PROGRAMME_TYPE,
      }.freeze

      DEGREE_CLASSES = {
        "Aegrotat" => "Aegrotat",
        "Distinction" => "Distinction",
        "First-class honours" => "FirstClassHonours",
        "Upper second-class honours (2:1)" => "UpperSecondClassHonours",
        "Lower second-class honours (2:2)" => "LowerSecondClassHonours",
        "Third-class honours" => "ThirdClassHonours",
        "Undivided second-class honours" => "UndividedSecondClassHonours",
        "Pass" => "Pass",
        "Merit" => "Merit",
        "Ordinary degree" => "Ordinary",
        "Other" => "Other",
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

      COUNTRY_CODE_EXCEPTIONS = {
        "CY" => "XC",
      }.freeze

      COUNTRY_EXCEPTIONS = {
        "Ajman" => "AE",
        "Abu Dhabi" => "AE",
        "Dubai" => "AE",
        "Fujairah" => "AE",
        "Ras al-Khaimah" => "AE",
        "Sharjah" => "AE",
        "Umm al-Quwain" => "AE",
        "Cyprus (European Union)" => "XA",
        "Cyprus (non European Union)" => "XB",
        "Taiwan" => "CN",
        "French Guiana" => "FR",
        "Guadeloupe" => "FR",
        "Puerto Rico" => "US",
        "Tristan da Cunha" => "GB",
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

      attr_reader :trainee, :degree

      def build_params
        {
          "firstName" => trainee.first_names,
          "middleName" => trainee.middle_names,
          "lastName" => trainee.last_name,
          "birthDate" => trainee.date_of_birth.iso8601,
          "emailAddress" => trainee.email,
          "slugid" => trainee.slug,
          "address" => address_params,
          "husid" => trainee.hesa_id,
          "genderCode" => GENDER_CODES[trainee.sex.to_sym],
          "initialTeacherTraining" => initial_teacher_training_params,
          "qualification" => qualification_params,
        }.compact
      end

      def address_params
        uk_address
      end

      def uk_address
        {

          "addressLine1" => nil,
          "addressLine2" => nil,
          "addressLine3" => nil,
          "city" => nil,
          "postalCode" => nil,
          "country" => nil,
        }
      end

      def initial_teacher_training_params
        {
          "providerUkprn" => trainee.provider.ukprn,
          "programmeStartDate" => trainee.itt_start_date&.iso8601,
          "programmeEndDate" => itt_end_date&.iso8601,
          "programmeType" => PROGRAMME_TYPE[trainee.training_route],
          "subject1" => course_subject_code(trainee.course_subject_one),
          "subject2" => course_subject_code(trainee.course_subject_two),
          "subject3" => course_subject_code(trainee.course_subject_three),
          "ageRangeFrom" => trainee.course_min_age,
          "ageRangeTo" => trainee.course_max_age,
          "ittQualificationAim" => ITT_QUALIFICATION_AIMS[trainee.hesa_metadatum&.itt_aim],
          "ittQualificationType" => itt_qualification_type,
          "trainingCountryCode" => find_country_code(trainee.iqts_country),
        }
      end

      def qualification_params
        return if degree.nil?
        return if Dqt::CodeSets::DegreeTypes::FOUNDATIONS.include?(degree.uk_degree_uuid)

        {
          "providerUkprn" => institution_ukprn,
          "countryCode" => country_code,
          "subject" => subject_code,
          "class" => DEGREE_CLASSES[degree.grade],
          "date" => graduation_date,
          "heQualificationType" => Dqt::CodeSets::DegreeTypes::MAPPING[degree.uk_degree_uuid],
        }
      end

      def itt_qualification_type
        return DQT_IQTS_PROGRAMME_TYPE if iqts_programme_type? && trainee.hesa_metadatum&.itt_qualification_aim.nil?

        ITT_QUALIFICATION_TYPES[trainee.hesa_metadatum&.itt_qualification_aim]
      end

      def course_subject_code(subject_name)
        # these three subjects are not coded by HESA so we've agreed these encodings with the DQT team
        return "999001" if subject_name == ::CourseSubjects::CITIZENSHIP
        return "999002" if subject_name == ::CourseSubjects::PHYSICAL_EDUCATION
        return "999003" if subject_name == ::CourseSubjects::DESIGN_AND_TECHNOLOGY

        Hesa::CodeSets::CourseSubjects::MAPPING.invert[subject_name]
      end

      def subject_code
        DfEReference::DegreesQuery.find_subject(name: degree.subject)&.hecos_code
      end

      def graduation_date
        return if degree.graduation_year.nil?

        Date.parse("01-01-#{degree.graduation_year}").iso8601
      end

      def institution_ukprn
        return if degree.institution_uuid.nil?

        DfEReference::DegreesQuery::INSTITUTIONS.one(degree.institution_uuid)&.ukprn
      end

      def country_code
        find_country_code(degree.uk? ? UNITED_KINGDOM_NOT_OTHERWISE_SPECIFIED : degree.country)
      end

      def itt_end_date
        trainee.itt_end_date || trainee.estimated_end_date
      end

      def iqts_programme_type?
        PROGRAMME_TYPE[trainee.training_route] == DQT_IQTS_PROGRAMME_TYPE
      end

      def find_country_code(country)
        return if country.blank?

        country_territory_code =
          DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.some(name: country).first&.id ||
            Hesa::CodeSets::Countries::MAPPING.find { |_, name| name.start_with?(country) }&.first ||
            COUNTRY_EXCEPTIONS[country]

        country_code = strip_territory_component(country_territory_code)
        apply_special_case_country_code_mappings(country_code)
      end

      def strip_territory_component(country_territory_code)
        country_territory_code.gsub(/-\w+$/, "")
      end

      def apply_special_case_country_code_mappings(country_code)
        COUNTRY_CODE_EXCEPTIONS.key?(country_code) ? COUNTRY_CODE_EXCEPTIONS[country_code] : country_code
      end
    end
  end
end
