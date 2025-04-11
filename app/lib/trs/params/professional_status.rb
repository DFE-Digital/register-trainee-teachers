# frozen_string_literal: true

module Trs
  module Params
    class ProfessionalStatus
      # Match the exceptions used in DQT
      COUNTRY_CODE_EXCEPTIONS = {
        "CY" => "XC",
      }.freeze

      def initialize(trainee:)
        @trainee = trainee
      end

      def to_json(*_args)
        params.to_json
      end

      def params
        @params ||= {
          "routeTypeId" => route_type_id,
          "status" => status,
          "awardedDate" => trainee.awarded_at&.to_date&.iso8601,
          "trainingStartDate" => trainee.itt_start_date.iso8601,
          "trainingEndDate" => trainee.itt_end_date&.iso8601,
          "trainingSubjectReferences" => training_subject_references,
          "trainingAgeSpecialism" => training_age_specialism,
          "trainingCountryReference" => training_country_reference,
          "trainingProviderUkprn" => trainee.provider.ukprn,
          "degreeTypeId" => degree_type_id,
          "isExemptFromInduction" => exempt_from_induction?,
        }.compact
      end

    private

      attr_reader :trainee

      def route_type_id
        # Map the training route to the TRS route type
        ::CodeSets::Trs::ROUTE_TYPES[trainee.training_route]
      end

      def status
        ::CodeSets::Trs.training_status(trainee.state, trainee.training_route)
      end

      def degree_type_id
        return nil if trainee.hesa_metadatum&.itt_qualification_aim.blank?

        ::CodeSets::Trs::DEGREE_TYPES[trainee.hesa_metadatum&.itt_qualification_aim]
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
        # these three subjects are not coded by HESA so we've agreed these encodings with the DQT team
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
        return nil unless trainee.training_route == "iqts" && trainee.iqts_country.present?

        find_country_code(trainee.iqts_country)
      end

      def find_country_code(country)
        return if country.blank?

        country_territory_code =
          DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.some(name: country).first&.id ||
          Hesa::CodeSets::Countries::MAPPING.find { |_, name| name.start_with?(country) }&.first

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

      def exempt_from_induction?
        # For the TRS API, returning nil when not applicable
        # Currently no induction exemption data available in the trainee model
        false
      end
    end
  end
end
