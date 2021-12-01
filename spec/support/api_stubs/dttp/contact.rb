# frozen_string_literal: true

module ApiStubs
  module Dttp
    module Contact
      def self.attributes
        {
          "firstname" => "John",
          "lastname" => "Smith",
          "emailaddress1" => "John@smith.com",
          "birthdate" => "1992-01-05",
          "gendercode" => "1",
          "address1_line1" => "34 Windsor Road",
          "address1_line2" => "EC London",
          "address1_line3" => "London",
          "address1_postalcode" => "EC7 1IY",
          "dfe_traineeid" => "UNIQUE_TRAINEE_ID",
          "_dfe_nationality_value" => "d17d640e-5c62-e711-80d1-005056ac45bb",
          "contactid" => SecureRandom.uuid,
          "_parentcustomerid_value" => SecureRandom.uuid,
        }
      end
    end
  end
end
