# frozen_string_literal: true

module Dttp
  module Parsers
    class Account
      class << self
        def to_provider_attributes(providers:)
          providers.map do |provider|
            {
              name: provider["name"],
              ukprn: provider["dfe_ukprn"],
              dttp_id: provider["accountid"],
            }
          end
        end
      end
    end
  end
end
