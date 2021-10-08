# frozen_string_literal: true

module Dttp
  class Client
    class Request
      include HTTParty
      base_uri Settings.dttp.api_base_url
      headers "Accept" => "application/json",
              "Content-Type" => "application/json;odata.metadata=minimal",
              "Authorization" => -> { "Bearer #{AccessToken.fetch}" }
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200
    POST_SUCCESS = 204
    POST_BATCH_SUCCESS = 200
    PATCH_SUCCESS = 204

    def self.get(...)
      response = Request.get(...)

      handle_response(response: response, status: GET_SUCCESS)
    end

    def self.patch(...)
      response = Request.patch(...)

      handle_response(response: response, status: PATCH_SUCCESS)
    end

    def self.post(...)
      response = Request.post(...)

      handle_response(response: response, status: POST_SUCCESS)
    end

    def self.post_batch(...)
      response = Request.post(...)

      handle_response(response: response, status: POST_BATCH_SUCCESS)
    end

    def self.handle_response(response:, status:)
      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") if response.code != status

      response
    end
  end
end
