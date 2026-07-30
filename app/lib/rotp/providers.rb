# frozen_string_literal: true

module Rotp
  class Providers
    def self.list
      response = Client.get(path, query: { academic_year: Settings.current_recruitment_cycle_year })
      response.parsed_response["data"]
    end

    def self.path
      "/#{Settings.rotp.api_version}/providers"
    end
  end
end
