# frozen_string_literal: true

module QualtricsApi
  class Client
    class Request
      include HTTParty
      base_uri Settings.qualtrics.base_url
      headers "X-API-TOKEN" => Settings.qualtrics.api_token,
              "Content-Type" => "application/json"
    end

    class HttpError < StandardError; end

    def self.post(...)
      response = Request.post(...)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") unless response.success?

      response
    end
  end
end
