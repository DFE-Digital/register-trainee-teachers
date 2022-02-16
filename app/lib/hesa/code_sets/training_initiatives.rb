# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingInitiatives
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # The follow initiatives do not have a matching enum:
      #  - 'D' => Primary mathematics specialist
      #  - 'P' => Abridged ITT course
      #  - 'Y' => Additional ITT place for PE with a priority subject
      MAPPING = {
        "M" => ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools],
        "13" => ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
        "14" => ROUTE_INITIATIVES_ENUMS[:now_teach],
      }.freeze
    end
  end
end
