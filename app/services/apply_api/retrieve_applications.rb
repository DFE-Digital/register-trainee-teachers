# frozen_string_literal: true

module ApplyApi
  class RetrieveApplications
    include ServicePattern

    SUCCESS = 200

    RECRUITMENT_CYCLE_YEAR = 2021

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
      @response ||= Client.get("/applications?#{params}")
    end

    def params
      params = "recruitment_cycle_year=#{RECRUITMENT_CYCLE_YEAR}"
      params += "&changed_since=#{changed_since}" if changed_since.present?
      params
    end

    def log_request!
      ApplyApplicationSyncRequest.create!(
        successful: response.code == SUCCESS,
        response_code: response.code,
      )
    end
  end
end
