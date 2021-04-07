# frozen_string_literal: true

module ApplyApi
  class RetrieveApplications
    include ServicePattern

    SUCCESS = 200

    class HttpError < StandardError; end

    def initialize(changed_since:)
      @changed_since = changed_since
    end

    def call
      log_request!

      if response.code != SUCCESS
        raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

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

    def log_request!
      ApplyApplicationSyncRequest.create!(
        successful: response.code == SUCCESS,
        response_code: response.code,
      )
    end
  end
end
