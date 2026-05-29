# frozen_string_literal: true

module Rotp
  class Providers
    def self.list
      response = Client.get(path)
      response.parsed_response["data"]
    end

    def self.path
      "/#{Settings.rotp.api_version}/providers"
    end
  end
end
