# frozen_string_literal: true

module Rotp
  class Client
    class Request
      include HTTParty

      base_uri Settings.rotp.base_url
      headers "Authorization" => "Bearer #{Settings.rotp.api_token}",
              "User-Agent" => "Register trainee teachers"
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200

    def self.get(...)
      response = Request.get(...)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") if response.code != GET_SUCCESS

      response
    end
  end
end
