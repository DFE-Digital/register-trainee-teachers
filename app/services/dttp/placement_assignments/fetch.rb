# frozen_string_literal: true

module Dttp
  module PlacementAssignments
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      attr_reader :trainee

      def initialize(trainee:)
        @trainee = trainee
      end

      def call
        response = Client.get("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        placement_assignment_json = JSON(response.body)

        Dttp::PlacementAssignment.new(placement_assignment_json: placement_assignment_json)
      end
    end
  end
end
