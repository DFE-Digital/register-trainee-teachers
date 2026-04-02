# frozen_string_literal: true

module Rotp
  class Client
    # Inner class holds HTTParty config so headers/base_uri are evaluated once at boot,
    # mirroring the pattern in TeacherTrainingApi::Client.
    class Request
      include HTTParty

      base_uri Settings.rotp.base_url
      headers "Authorization" => "Bearer #{Settings.rotp.api_token}",
              "User-Agent" => "Register trainee teachers"
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200

    # Delegates to HTTParty and raises on non-200 so callers don't need to check status.
    def self.get(...)
      response = Request.get(...)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") if response.code != GET_SUCCESS

      response
    end
  end
end
