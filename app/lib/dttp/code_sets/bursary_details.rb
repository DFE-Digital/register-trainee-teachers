# frozen_string_literal: true

module Dttp
  module CodeSets
    module BursaryDetails
      # TODO: where to put :early_years_salaried. Other IDs in DTTP:
      # School direct salaried = 3036b79f-9fc7-eb11-bacc-000d3ab7dcfe
      # Scholarship = 188375c2-7722-e711-80c8-0050568902d3
      # No bursary awarded = 1c8375c2-7722-e711-80c8-0050568902d3
      # Service leaver bursary = 6ca6f51f-2189-e811-80f7-005056ac45bb
      MAPPING = {
        # Postgraduate bursary:
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => { entity_id: "8c629dd7-bfc3-eb11-bacc-000d3addca7a" },
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => { entity_id: "8c629dd7-bfc3-eb11-bacc-000d3addca7a" },
        # Undergraduate bursary
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => { entity_id: "96756cc6-6041-e811-80f2-005056ac45bb" },
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => { entity_id: "96756cc6-6041-e811-80f2-005056ac45bb" },
        "school_direct_salaried" => { entity_id: "3036b79f-9fc7-eb11-bacc-000d3ab7dcfe" },
      }.freeze
    end
  end
end
