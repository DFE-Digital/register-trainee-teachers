# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveLeadSchools
    include ServicePattern

    DEFAULT_PATH = "/recruitment_cycles/#{Settings.current_recruitment_cycle_year}/providers?filter[provider_type]=lead_school&sort=name".freeze

    def initialize(request_uri: nil)
      @request_uri = request_uri.presence || DEFAULT_PATH
    end

    def call
      JSON(response.body, symbolize_names: true)
    end

  private

    attr_reader :request_uri

    def response
      @response ||= Client.get(request_uri)
    end
  end
end
