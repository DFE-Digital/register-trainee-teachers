# frozen_string_literal: true

module ApplyApi
  class RetrieveApplications
    include ServicePattern

    def initialize(changed_since:)
      @changed_since = changed_since
    end

    def call
      applications
    end

  private

    attr_reader :changed_since

    def applications
      JSON(response.body)["data"]
    end

    def response
      @response ||= Client.get("/applications?#{query}")
    end

    def query
      {
        recruitment_cycle_year: Settings.current_recruitment_cycle_year,
        changed_since: changed_since,
      }.compact.to_query
    end
  end
end
