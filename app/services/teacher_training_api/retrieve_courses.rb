# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCourses
    include ServicePattern

    class HttpError < StandardError; end

    def initialize(provider:)
      @provider = provider
    end

    def call
      if response.code != 200
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)["data"]
    end

  private

    attr_reader :provider

    # TODO: Make the recruitment cycle dynamic once we have a concept of cycles.
    def response
      @response ||= Client.get("/recruitment_cycles/2021/providers/#{provider.code}/courses")
    end
  end
end
