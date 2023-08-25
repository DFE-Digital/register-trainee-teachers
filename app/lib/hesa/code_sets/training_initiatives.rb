# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingInitiatives
      # https://www.hesa.ac.uk/collection/c22053/e/initiatives
      # The commented out lines do not have a matching enum in Register.
      MAPPING = {
        # "001"	=> Abridged ITT course,
        "009"	=> ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools],
        # "011"	=> Primary mathematics specialist,
        # "019"	=> Additional ITT place for PE with a priority subject,
        "025"	=> ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
        "026"	=> ROUTE_INITIATIVES_ENUMS[:now_teach],
        "036" => ROUTE_INITIATIVES_ENUMS[:international_relocation_payment],
      }.freeze
    end
  end
end
