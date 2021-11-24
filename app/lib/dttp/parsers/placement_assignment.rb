# frozen_string_literal: true

module Dttp
  module Parsers
    class PlacementAssignment
      class << self
        def to_attributes(placement_assignments:)
          placement_assignments.map do |placement_assignment|
            {
              dttp_id: placement_assignment["dfe_placementassignmentid"],
              response: placement_assignment,
            }
          end
        end
      end
    end
  end
end
