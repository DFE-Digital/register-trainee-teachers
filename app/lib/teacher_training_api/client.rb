# frozen_string_literal: true

module TeacherTrainingApi
  class Client
    class Request
      include HTTParty

      base_uri Settings.teacher_training_api.base_url
      headers "User-Agent" => "Register for teacher training"
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
