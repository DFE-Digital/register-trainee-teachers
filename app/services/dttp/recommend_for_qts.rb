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
      response = Client.patch(
        "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})",
        body: params.to_json,
      )

      raise Error, response.body if response.code != 204

      response
    end

  private

    def params
      @params ||= Params::PlacementAssignmentOutcome.new(trainee: trainee)
    end
  end
end
