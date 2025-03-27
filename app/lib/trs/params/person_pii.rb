# frozen_string_literal: true

module Trs
  module Params
    class PersonPii
      def initialize(trainee:)
        @trainee = trainee
      end

      def to_json(*_args)
        params.to_json
      end

    private

      attr_reader :trainee

      def params
        @params ||= {
          "firstName" => trainee.first_names,
          "middleName" => trainee.middle_names,
          "lastName" => trainee.last_name,
          "dateOfBirth" => trainee.date_of_birth.iso8601,
          "emailAddresses" => [
            trainee.email,
          ],
          "gender" => Config::GENDER_CODES[trainee.sex.to_sym],
        }
      end
    end
  end
end
