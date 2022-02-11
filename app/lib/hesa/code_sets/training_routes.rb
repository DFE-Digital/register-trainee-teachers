# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingRoutes
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      MAPPING = {
        "01" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        "02" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "03" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "09" => TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        "10" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
      }.freeze
    end
  end
end
