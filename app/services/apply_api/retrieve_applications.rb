# frozen_string_literal: true

module ApplyApi
  class RetrieveApplications
    include ServicePattern

    def initialize(changed_since:, recruitment_cycle_year:)
      @changed_since = changed_since
      @recruitment_cycle_year = recruitment_cycle_year
    end

    def call
      applications
    end

  private

    attr_reader :changed_since, :recruitment_cycle_year

    def applications
      JSON(response.body)["data"]
    end

    def response
      @response ||= Client.get("/applications?#{query}")
    end

    def query
      {
        recruitment_cycle_year: recruitment_cycle_year,
        changed_since: changed_since&.utc&.iso8601,
      }.compact.to_query
    end
  end
end
