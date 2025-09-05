# frozen_string_literal: true

module RecruitsApi
  class Client
    class Request
      include HTTParty

      base_uri Settings.recruits_api.base_url
      headers "Accept" => "application/json",
              "Content-Type" => "application/json",
              "Authorization" => -> { "Bearer #{Settings.recruits_api.auth_token}" },
              "User-Agent" => "Register for teacher training (#{Settings.environment.name})"
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200

    def self.get(params)
      response = Request.get("/applications?#{query(params)}")

      if response.code != GET_SUCCESS
        log_request!(response, params)
        raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
      end

      response
    end

    def self.log_request!(response, params)
      ApplyApplicationSyncRequest.create!(
        successful: response.code == GET_SUCCESS,
        response_code: response.code,
        recruitment_cycle_year: params[:recruitment_cycle_year],
      )
    end

    def self.query(params)
      params.compact.to_query
    end
  end
end
