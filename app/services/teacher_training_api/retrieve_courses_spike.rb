# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCoursesSpike
    include ServicePattern

    class Error < StandardError; end

    DEFAULT_PATH = "/courses?filter[findable]=true&include=accredited_body,provider"

    def initialize(request_uri:)
      @request_uri = request_uri.presence || DEFAULT_PATH
    end

    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)
    end

  private

    attr_reader :request_uri

    def response
      @response ||= Client.get(request_uri)
    end
  end
end
