# frozen_string_literal: true

module Dqt
  class Client
    class Request
      include HTTParty
      base_uri Settings.dqt.base_url
      headers "Accept" => "application/json",
              "Content-Type" => "application/json;odata.metadata=minimal",
              "Authorization" => "Bearer #{Settings.dqt.api_key}"
    end

    class HttpError < StandardError; end

    GET_SUCCESSES = [200].freeze
    PUT_SUCCESSES = [200, 201].freeze
    PATCH_SUCCESSES = [204].freeze

    def self.get(...)
      response = Request.get(...)

      handle_response(response: response, statuses: GET_SUCCESSES)
    end

    def self.put(...)
      response = Request.put(...)

      handle_response(response: response, statuses: PUT_SUCCESSES)
    end

    def self.patch(...)
      response = Request.patch(...)

      handle_response(response: response, statuses: PATCH_SUCCESSES)
    end

    def self.handle_response(response:, statuses:)
      return JSON.parse(response.body) if statuses.include?(response.code)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
    end
  end
end
