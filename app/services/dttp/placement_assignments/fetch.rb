# frozen_string_literal: true

module Dttp
  module PlacementAssignments
    class Fetch
      include ServicePattern

      class HttpError < StandardError; end

      attr_reader :dttp_id

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        response = Client.get("/dfe_placementassignments(#{dttp_id})")

        if response.code != 200
          raise HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
        end

        placement_assignment_data = JSON(response.body)

        Dttp::PlacementAssignment.new(placement_assignment_data: placement_assignment_data)
      end
    end
  end
end
