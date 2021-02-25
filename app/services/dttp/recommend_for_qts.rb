# frozen_string_literal: true

module Dttp
  class RecommendForQTS
    include ServicePattern

    class Error < StandardError; end

    attr_reader :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      body = {
        dfe_datestandardsassessmentpassed: trainee.outcome_date.in_time_zone.iso8601,
      }.to_json

      response = Client.patch(
        "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        body: body,
      )

      if response.code != 204
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      response
    end
  end
end
