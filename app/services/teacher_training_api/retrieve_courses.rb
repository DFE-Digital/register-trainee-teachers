# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCourses
    include ServicePattern

    class Error < StandardError; end

    DEFAULT_PATH = "/courses?filter[findable]=true&include=accredited_body,provider&sort=name,provider.provider_name"

    def initialize(request_uri: nil)
      @request_uri = request_uri.presence || DEFAULT_PATH
    end

    def call
      response = Client.get(request_uri)

      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body, symbolize_names: true)
    end

  private

    attr_reader :request_uri
  end
end
