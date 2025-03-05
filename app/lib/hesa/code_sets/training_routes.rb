# frozen_string_literal: true

module Hesa
  module CodeSets
    module TrainingRoutes
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "02" => TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee],
        "03" => TRAINING_ROUTE_ENUMS[:school_direct_salaried],
        "09" => TRAINING_ROUTE_ENUMS[:opt_in_undergrad],
        "10" => TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship],
        "11" => TRAINING_ROUTE_ENUMS[:provider_led_undergrad],
        "12" => TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        "14" => TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship],
      }.freeze
    end
  end
end
