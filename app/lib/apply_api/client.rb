# frozen_string_literal: true

module ApplyApi
  class Client
    class Request
      include HTTParty
      base_uri Settings.apply_api.base_url
      headers "Accept" => "application/json",
              "Content-Type" => "application/json",
              "Authorization" => -> { "Bearer #{Settings.apply_api.auth_token}" },
              "User-Agent" => "Register for teacher training (#{Settings.environment.name})"
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200

    def self.get(...)
      response = Request.get(...)

      log_request!(response)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") if response.code != GET_SUCCESS

      response
    end

    def self.log_request!(response)
      ApplyApplicationSyncRequest.create!(
        successful: response.code == GET_SUCCESS,
        response_code: response.code,
      )
    end
  end
end
