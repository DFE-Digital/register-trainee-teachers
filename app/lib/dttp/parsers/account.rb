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
              response: provider,
            }
          end
        end

        def to_school_attributes(schools:)
          schools.map do |school|
            {
              name: school["name"],
              urn: school["dfe_urn"],
              dttp_id: school["accountid"],
              status_code: school["statuscode"],
            }
          end
        end

        def to_account_attributes(accounts:)
          accounts.map do |account|
            {
              name: account["name"],
              ukprn: account["dfe_ukprn"],
              urn: account["dfe_urn"],
              accreditation_id: account["dfe_providerid"],
              dttp_id: account["accountid"],
              response: account,
            }
          end
        end
      end
    end
  end
end
