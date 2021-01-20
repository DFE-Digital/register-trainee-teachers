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

      attr_reader :trainee, :trainee_creator_dttp_id, :params

      def initialize(trainee, trainee_creator_dttp_id = nil)
        @trainee = trainee
        @trainee_creator_dttp_id = trainee_creator_dttp_id
        @params = build_params

        if trainee_creator_dttp_id
          @params.merge!({
            "dfe_CreatedById@odata.bind" => "/contacts(#{trainee_creator_dttp_id})",
            "dfe_trnassessmentdate" => Time.zone.now.iso8601,
          })
        end
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
          "dfe_EthnicityId@odata.bind" => "/dfe_ethnicities(#{contact_dttp_ethnicity_id})",
          "dfe_DisibilityId@odata.bind" => "/dfe_disabilities(#{contact_dttp_disability_id})",
          "parentcustomerid_account@odata.bind" => "/accounts(#{trainee.provider.dttp_id})",
        }
      end

      def contact_dttp_ethnicity_id
        dttp_ethnicity_id(diversity_disclosed? ? trainee.ethnic_background : Diversities::NOT_PROVIDED)
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
        trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled]
      end

      def trainee_disability_not_provided?
        trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
      end
    end
  end
end
