# frozen_string_literal: true

module Dttp
  module CodeSets
    module TrainingInitiatives
      EBACC = "883398f8-0d89-e811-80f7-005056ac45bb"

      # DTTP recognise future_teaching_scholars as a route not an initiative,
      # hence there is no mapping. See Dttp::CodeSets::Routes.
      MAPPING = {
        ROUTE_INITIATIVES_ENUMS[:transition_to_teach] => { entity_id: "544a6435-e2af-ea11-a812-000d3ab55801" },
        ROUTE_INITIATIVES_ENUMS[:troops_to_teachers] => { entity_id: "5608fd3f-276e-e711-80d2-005056ac45bb" },
        ROUTE_INITIATIVES_ENUMS[:now_teach] => { entity_id: "04516b48-e2af-ea11-a812-000d3ab55801" },
        ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools] => { entity_id: "6a08fd3f-276e-e711-80d2-005056ac45bb" },
      }.freeze
    end
  end
end
