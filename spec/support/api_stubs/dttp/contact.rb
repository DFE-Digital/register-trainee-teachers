# frozen_string_literal: true

module ApiStubs
  module Dttp
    module Contact
      def self.attributes
        {
          "firstname" => "John",
          "lastname" => "Smith",
          "emailaddress1" => "John@smith.com",
          "contactid" => SecureRandom.uuid,
          "_parentcustomerid_value" => SecureRandom.uuid,
        }
      end
    end
  end
end
