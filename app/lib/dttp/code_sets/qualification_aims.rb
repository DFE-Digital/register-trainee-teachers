# frozen_string_literal: true

module Dttp
  module CodeSets
    module QualificationAims
      EYTS = "d446cd4b-4d9c-e711-80d9-005056ac45bb"
      QTS = "68cbae32-7389-e711-80d8-005056ac45bb"
      # Most of these are currently mapped to "Qualified Teacher Status (QTS)/registration with the DFE"
      # The full DTTP list contains a number of qualification aims which our app isn't setup to collect.
      # The DTTP qualification aim GUIDS will likely need to be updated once we collect more details about the trainee's qualification aim.
      MAPPING = {
        TRAINING_ROUTE_ENUMS[:assessment_only] => { entity_id: QTS },
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => { entity_id: QTS },
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => { entity_id: QTS },
        TRAINING_ROUTE_ENUMS[:early_years_undergrad] => { entity_id: EYTS },
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => { entity_id: QTS },
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => { entity_id: QTS },
        TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => { entity_id: "e0113eff-141e-e711-80c8-0050568902d3" },
        TRAINING_ROUTE_ENUMS[:early_years_postgrad] => { entity_id: EYTS },
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => { entity_id: "d4113eff-141e-e711-80c8-0050568902d3" },
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => { entity_id: EYTS },
      }.freeze
    end
  end
end
