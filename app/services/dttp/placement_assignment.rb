# frozen_string_literal: true

module Dttp
  class PlacementAssignment
    attr_reader :placement_assignment_json

    def initialize(placement_assignment_json:)
      @placement_assignment_json = placement_assignment_json
    end

    def programme_start_date
      placement_assignment_json[:dfe_programmestartdate]
    end

    def programme_end_date
      placement_assignment_json[:dfe_programmeenddate]
    end

    def placement_assignment_id
      placement_assignment_json[:dfe_placementassignmentid]
    end

    def provider_id_value
      placement_assignment_json[:_dfe_providerid_value]
    end
  end
end
