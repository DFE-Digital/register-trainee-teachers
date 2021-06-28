# frozen_string_literal: true

module Dttp
  module CodeSets
    module TrainingInitiatives
      MAPPING = {
        ROUTE_INITIATIVES_ENUMS[:transition_to_teach] => { entity_id: "544a6435-e2af-ea11-a812-000d3ab55801" },
        ROUTE_INITIATIVES_ENUMS[:now_teach] => { entity_id: "04516b48-e2af-ea11-a812-000d3ab55801" },
        ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools] => { entity_id: "6a08fd3f-276e-e711-80d2-005056ac45bb" },
        ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => { entity_id: "" },
      }.freeze
    end
  end
end
