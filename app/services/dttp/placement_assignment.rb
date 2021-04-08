# frozen_string_literal: true

module Dttp
  class PlacementAssignment
    def initialize(placement_assignment_data:)
      @placement_assignment_data = placement_assignment_data
    end

    def programme_start_date
      placement_assignment_data["dfe_programmestartdate"]
    end

    def programme_end_date
      placement_assignment_data["dfe_programmeenddate"]
    end

    def placement_assignment_id
      placement_assignment_data["dfe_placementassignmentid"]
    end

    def provider_id_value
      placement_assignment_data["_dfe_providerid_value"]
    end

    def updated_at
      placement_assignment_data["modifiedon"]
    end

  private

    attr_reader :placement_assignment_data
  end
end
