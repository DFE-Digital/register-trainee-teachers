# frozen_string_literal: true

module Dttp
  module Params
    class Contact
      include Mappable

      GENDER_CODES = {
        male: 1,
        female: 2,
        other: 389_040_000,
        gender_not_provided: nil,
      }.freeze

      TRAINEE_CONTACT_TYPE_DTTP_ID = "faba11c7-07d9-e711-80e1-005056ac45bb"

      attr_reader :trainee, :created_by_dttp_id, :params

      def initialize(trainee, created_by_dttp_id = nil)
        @trainee = trainee
        @created_by_dttp_id = created_by_dttp_id
        @params = build_params

        append_create_only_params if created_by_dttp_id
      end

      def to_json(*_args)
        params.to_json
      end

    private

      def build_params
        {
          "firstname" => trainee.first_names,
          "lastname" => trainee.last_name,
          "address1_line1" => trainee.address_line_one,
          "address1_line2" => trainee.address_line_two,
          "address1_line3" => trainee.town_city,
          "address1_postalcode" => trainee.postcode,
          "birthdate" => trainee.date_of_birth.to_s,
          "emailaddress1" => trainee.email,
          "gendercode" => GENDER_CODES[trainee.gender.to_sym],
          "dfe_traineeid" => trainee.trainee_id || "NOTPROVIDED",
          "dfe_Nationality@odata.bind" => "/dfe_nations(#{contact_dttp_nationality_id})",
          "dfe_EthnicityId@odata.bind" => "/dfe_ethnicities(#{contact_dttp_ethnicity_id})",
          "dfe_DisibilityId@odata.bind" => "/dfe_disabilities(#{contact_dttp_disability_id})",
          "parentcustomerid_account@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
        }
      end

      def append_create_only_params
        params.merge!({
          "dfe_ContactTypeId@odata.bind" => "/dfe_contacttypes(#{TRAINEE_CONTACT_TYPE_DTTP_ID})",
          "dfe_CreatedById@odata.bind" => "/contacts(#{created_by_dttp_id})",
          "dfe_trnassessmentdate" => Time.zone.now.iso8601,
        })
      end

      def contact_dttp_nationality_id
        dttp_nationality_id(selected_nationality)
      end

      def contact_dttp_ethnicity_id
        dttp_ethnicity_id(diversity_disclosed? ? resolve_ethnicity_value : Diversities::NOT_PROVIDED)
      end

      def contact_dttp_disability_id
        dttp_disability_id(diversity_disclosed? ? dttp_disability : Diversities::NOT_PROVIDED)
      end

      def dttp_disability
        return Diversities::NO_KNOWN_DISABILITY if trainee_not_disabled?
        return Diversities::NOT_PROVIDED if trainee_disability_not_provided?

        disability_names = trainee.disabilities.pluck(:name)
        disability_names.size == 1 ? disability_names.first : Diversities::MULTIPLE_DISABILITIES
      end

      def diversity_disclosed?
        trainee.diversity_disclosure == Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
      end

      def trainee_not_disabled?
        trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
      end

      def trainee_disability_not_provided?
        trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
      end

      def selected_nationality
        nationalities = trainee.nationalities.pluck(:name)
        british_or_irish = ->(nationality) { nationality == CodeSets::Nationalities::BRITISH || CodeSets::Nationalities::IRISH }

        (nationalities.select(&british_or_irish).presence || nationalities).first
      end

      def resolve_ethnicity_value
        return Diversities::NOT_PROVIDED if trainee.not_provided_ethnic_group?

        trainee.ethnic_background
      end
    end
  end
end
