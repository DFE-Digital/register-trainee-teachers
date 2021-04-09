# frozen_string_literal: true

module ApiStubs
  module Dttp
    module Provider
      def self.attributes
        {
          "name" => "Test Organisation",
          "dfe_ukprn" => "A123Q",
          "accountid" => SecureRandom.uuid,
        }
      end
    end
  end
end
