# frozen_string_literal: true

module Dttp
  module PlacementAssignments
    class Fetch
      include ServicePattern

      def initialize(dttp_id:)
        @dttp_id = dttp_id
      end

      def call
        placement_assignment_data = JSON(response.body)

        Dttp::PlacementAssignment.new(placement_assignment_data: placement_assignment_data)
      end

    private

      attr_reader :dttp_id

      def response
        @response ||= Client.get("/dfe_placementassignments(#{dttp_id})")
      end
    end
  end
end
