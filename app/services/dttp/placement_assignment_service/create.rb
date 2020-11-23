# frozen_string_literal: true

module Dttp
  module PlacementAssignmentService
    class Create < Base
      def call
        body = trainee.placement_assignment_params.to_json
        response = Client.post("/dfe_placementassignments", { body: body, headers: headers })
        parse_contactid(response)
      end
    end
  end
end
