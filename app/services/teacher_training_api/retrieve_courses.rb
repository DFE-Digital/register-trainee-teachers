# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCourses
    include ServicePattern

    class Error < StandardError; end

    def initialize(provider:)
      @provider = provider
    end

    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      JSON(response.body)["data"]
    end

  private

    attr_reader :provider

    def response
      @response ||= Client.get("/recruitment_cycles/#{Settings.current_recruitment_cycle_year}/providers/#{provider.code}/courses")
    end
  end
end
