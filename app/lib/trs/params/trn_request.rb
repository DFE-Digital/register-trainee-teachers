# frozen_string_literal: true

module Trs
  module Params
    class TrnRequest
      GENDER_CODES = {
        male: "Male",
        female: "Female",
        other: "Other",
        prefer_not_to_say: "NotProvided",
        sex_not_provided: "NotAvailable",
      }.freeze

      def initialize(trainee:, request_id:)
        @trainee = trainee
        @request_id = request_id
      end

      def to_json(*_args)
        params.to_json
      end

    private

      attr_reader :trainee, :request_id

      def params
        @params ||= {
          "requestId" => request_id,
          "person" => person_details,
          "identityVerified" => nil,
          "oneLoginUserSubject" => nil,
        }
      end

      def person_details
        {
          "firstName" => trainee.first_names,
          "middleName" => trainee.middle_names,
          "lastName" => trainee.last_name,
          "dateOfBirth" => trainee.date_of_birth.iso8601,
          "emailAddresses" => [
            trainee.email,
          ],
          "nationalInsuranceNumber" => nil,
          "address" => address_details,
          "gender" => GENDER_CODES[trainee.sex.to_sym],
        }
      end

      def address_details
        {
          "addressLine1" => nil,
          "addressLine2" => nil,
          "addressLine3" => nil,
          "city" => nil,
          "postcode" => nil,
          "country" => nil,
        }
      end
    end
  end
end
