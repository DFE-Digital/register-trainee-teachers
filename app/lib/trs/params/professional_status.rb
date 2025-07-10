# frozen_string_literal: true

module Trs
  module Params
    class ProfessionalStatus
      # Match the exceptions used in DQT
      COUNTRY_CODE_EXCEPTIONS = {
        "CY" => "XC",
      }.freeze

      # This is a fallback mapping for territories that are no longer in the reference data gem
      TERRITORY_FALLBACK_MAPPING = {
        # United Arab Emirates
        "Ajman" => "AE",
        "Abu Dhabi" => "AE",
        "Dubai" => "AE",
        "Fujairah" => "AE",
        "Ras al-Khaimah" => "AE",
        "Sharjah" => "AE",
        "Umm al-Quwain" => "AE",

        # Caribbean Netherlands - special municipalities of the Netherlands
        "Bonaire" => "NL",
        "Saba" => "NL",
        "Sint Eustatius" => "NL",

        # Spain territories - autonomous cities of Spain
        "Ceuta" => "ES",
        "Melilla" => "ES",

        # Saint Helena - British Overseas Territories
        "Ascension" => "GB",
        "Saint Helena" => "GB",
        "Tristan da Cunha" => "GB",

        # United States Minor Outlying Islands - use US code
        "Johnston Atoll" => "US",
        "Midway Islands" => "US",
        "Navassa Island" => "US",
        "Wake Island" => "US",
        "Baker Island" => "US",
        "Howland Island" => "US",
        "Jarvis Island" => "US",
        "Kingman Reef" => "US",
        "Palmyra Atoll" => "US",
      }.freeze

      def initialize(trainee:)
        @trainee = trainee
      end

      def to_json(*_args)
        params.to_json
      end

      def params
        @params ||= {
          "routeToProfessionalStatusTypeId" => route_to_professional_status_type_id,
          "status" => status,
          "holdsFrom" => trainee.outcome_date&.to_date&.iso8601,
          "trainingStartDate" => trainee.itt_start_date&.iso8601 || trainee.trainee_start_date&.iso8601,
          "trainingEndDate" => trainee.itt_end_date&.iso8601 || trainee.estimated_end_date&.iso8601,
          "trainingSubjectReferences" => training_subject_references,
          "trainingAgeSpecialism" => training_age_specialism,
          "trainingCountryReference" => training_country_reference,
          "trainingProviderUkprn" => trainee.provider.ukprn,
          "degreeTypeId" => degree_type_id,
          "isExemptFromInduction" => nil,
        }.compact
      end

    private

      attr_reader :trainee

      def itt_qualification_aim
        trainee.hesa_metadatum&.itt_qualification_aim || trainee.hesa_trainee_detail&.itt_qualification_aim
      end

      def route_to_professional_status_type_id
        ::CodeSets::Trs::ROUTE_TYPES[trainee.training_route]
      end

      def status
        ::CodeSets::Trs.training_status(trainee.state, trainee.training_route)
      end

      def degree_type_id
        return nil if itt_qualification_aim.blank?

        ::CodeSets::Trs::DEGREE_TYPES[itt_qualification_aim]
      end

      def training_subject_references
        return [] if trainee.course_subject_one.blank?

        [].tap do |subj|
          subj << subject_reference(trainee.course_subject_one) if trainee.course_subject_one.present?
          subj << subject_reference(trainee.course_subject_two) if trainee.course_subject_two.present?
          subj << subject_reference(trainee.course_subject_three) if trainee.course_subject_three.present?
        end
      end

      def subject_reference(subject_name)
        # These three subjects are not coded by HESA so we've agreed these encodings with the DQT team
        return "999001" if subject_name == ::CourseSubjects::CITIZENSHIP
        return "999002" if subject_name == ::CourseSubjects::PHYSICAL_EDUCATION
        return "999003" if subject_name == ::CourseSubjects::DESIGN_AND_TECHNOLOGY

        Hesa::CodeSets::CourseSubjects::MAPPING.invert[subject_name]
      end

      def training_age_specialism
        return nil unless trainee.course_min_age.present? && trainee.course_max_age.present?

        {
          "type" => "Range",
          "from" => trainee.course_min_age,
          "to" => trainee.course_max_age,
        }
      end

      def training_country_reference
        return "GB" unless trainee.iqts? && trainee.iqts_country.present?

        find_country_code(trainee.iqts_country)
      end

      def find_country_code(country)
        return if country.blank?

        # Check for direct mapping in territory fallback first
        return TERRITORY_FALLBACK_MAPPING[country] if TERRITORY_FALLBACK_MAPPING.key?(country)

        # Try the reference data lookup
        country_territory_code =
          DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.some(name: country).first&.id

        # If reference data lookup fails, try the HESA mapping as fallback
        if country_territory_code.blank?
          country_territory_code = Hesa::CodeSets::Countries::MAPPING.find { |_, name| name.start_with?(country) }&.first
        end

        country_code = strip_territory_component(country_territory_code)
        apply_special_case_country_code_mappings(country_code)
      end

      def strip_territory_component(country_territory_code)
        return if country_territory_code.blank?

        # Match DQT implementation using regex
        country_territory_code.gsub(/-\w+$/, "")
      end

      def apply_special_case_country_code_mappings(country_code)
        return if country_code.blank?

        # Use the same mappings as DQT
        COUNTRY_CODE_EXCEPTIONS.key?(country_code) ? COUNTRY_CODE_EXCEPTIONS[country_code] : country_code
      end
    end
  end
end
