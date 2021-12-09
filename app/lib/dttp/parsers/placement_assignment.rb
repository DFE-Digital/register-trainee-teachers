# frozen_string_literal: true

module Dttp
  module Parsers
    class PlacementAssignment
      class << self
        def to_attributes(placement_assignments:)
          placement_assignments.map do |placement_assignment|
            {
              dttp_id: placement_assignment["dfe_placementassignmentid"],
              contact_dttp_id: placement_assignment["_dfe_contactid_value"],
              provider_dttp_id: placement_assignment["_dfe_providerid_value"],
              academic_year: placement_assignment["_dfe_academicyearid_value"],
              programme_start_date: placement_assignment["dfe_programmestartdate"],
              programme_end_date: placement_assignment["dfe_programmeenddate"],
              trainee_status: placement_assignment["_dfe_traineestatusid_value"],
              response: placement_assignment,
            }
          end
        end
      end
    end
  end
end
