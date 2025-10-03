# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingInitiatives
      # https://www.hesa.ac.uk/collection/c22053/e/initiatives
      MAPPING = {
        "009"	=> ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools],
        "025"	=> ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
        "026"	=> ROUTE_INITIATIVES_ENUMS[:now_teach],
        "036" => ROUTE_INITIATIVES_ENUMS[:international_relocation_payment],
      }.freeze
    end
  end
end
