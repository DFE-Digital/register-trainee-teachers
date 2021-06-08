# frozen_string_literal: true

module ApiStubs
  module Dttp
    module School
      def self.attributes
        {
          "name" => "Test School",
          "dfe_urn" => "145694",
          "accountid" => SecureRandom.uuid,
        }
      end
    end
  end
end
