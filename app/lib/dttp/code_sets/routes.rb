# frozen_string_literal: true

module Dttp
  module CodeSets
    module Routes
      MAPPING = {
        TRAINING_ROUTE_ENUMS[:assessment_only] => { entity_id: "99f435d5-a626-e711-80c8-0050568902d3" },
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => { entity_id: "6189922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:early_years_undergrad] => { entity_id: "6b89922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => { entity_id: "6f89922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => { entity_id: "7789922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:early_years_postgrad] => { entity_id: "6789922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => { entity_id: "6589922e-acc2-e611-80be-00155d010316" },
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => { entity_id: "cf9154ee-5678-e811-80f6-005056ac45bb" },
        # DTTP recognise future_teaching_scholars as a route not an initiative, hence this 'odd' mapping.
        ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => { entity_id: "e7b6efbc-8d96-ea11-a811-000d3ab55801" },
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => { entity_id: "6989922e-acc2-e611-80be-00155d010316" },
      }.freeze
    end
  end
end
