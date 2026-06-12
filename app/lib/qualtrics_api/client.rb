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

      raise(http_error(response)) unless response.success?

      response
    end

    def self.fetch_result(response, key)
      parsed = JSON.parse(response.body)
      value = parsed.dig("result", key)
      return value if value.present?

      raise(http_error(response, parsed:))
    rescue JSON::ParserError
      raise(HttpError, "status: #{response.code}, invalid JSON body: #{response.body}")
    end

    def self.http_error(response, parsed: nil)
      parsed ||= JSON.parse(response.body)
      error = parsed.dig("meta", "error") || parsed["error"]
      detail = if error.is_a?(Hash)
                 [error["errorCode"], error["errorMessage"]].compact.join(": ")
               else
                 parsed["result"].nil? ? "missing result in response" : "request failed"
               end

      HttpError.new("status: #{response.code}, #{detail}, body: #{response.body}")
    rescue JSON::ParserError
      HttpError.new("status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
    end
    private_class_method :http_error
  end
end
