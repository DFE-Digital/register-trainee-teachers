# frozen_string_literal: true

module Fauapi
  class Client
    class Request
      include HTTParty

      base_uri Settings.fauapi.base_url
      headers "Accept" => "application/json",
              "Content-Type" => "application/json",
              "Authorization" => -> { "Bearer #{Settings.fauapi.api_key}" }
    end

    class HttpError < StandardError; end

    SUCCESS_CODES = [200, 201, 204].freeze

    def self.import(manifest)
      post("/api/tasks/apis/import", body: manifest.to_json)
    end

    def self.list_apis
      get("/api/tasks/apis")
    end

    def self.publish(api_id)
      put("/api/tasks/apis/#{api_id}/publish")
    end

    def self.get(path, options = {})
      handle_response(response: Request.get(path, options))
    end

    def self.post(path, options = {})
      handle_response(response: Request.post(path, options))
    end

    def self.put(path, options = {})
      handle_response(response: Request.put(path, options))
    end

    def self.handle_response(response:)
      return parse_body(response) if SUCCESS_CODES.include?(response.code)

      raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
    end

    def self.parse_body(response)
      body = response.body.to_s
      return {} if body.blank?

      JSON.parse(body)
    end
    private_class_method :parse_body
  end
end
