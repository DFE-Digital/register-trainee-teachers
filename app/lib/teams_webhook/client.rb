# frozen_string_literal: true

module TeamsWebhook
  class Client
    class Request
      include HTTParty

      headers "Content-Type" => "application/json"
    end

    class HttpError < StandardError; end

    def self.post(...)
      response = Request.post(...)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}") unless response.success?

      response
    end
  end
end
