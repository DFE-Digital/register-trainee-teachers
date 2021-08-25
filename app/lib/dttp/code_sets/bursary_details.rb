# frozen_string_literal: true

module Dttp
  module CodeSets
    module BursaryDetails
      MAPPING = {
        # Postgraduate bursary:
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => { entity_id: "8c629dd7-bfc3-eb11-bacc-000d3addca7a" },
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => { entity_id: "8c629dd7-bfc3-eb11-bacc-000d3addca7a" },
        # Undergraduate bursary
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => { entity_id: "96756cc6-6041-e811-80f2-005056ac45bb" },
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => { entity_id: "96756cc6-6041-e811-80f2-005056ac45bb" },
        # EYITT-GEB
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => { entity_id: "6292647b-91e2-e811-8136-5065f38bc341" },
        # Tier one
        BURSARY_TIER_ENUMS[:tier_one] => { entity_id: "001bf834-33ff-eb11-94ef-00224899ca99" },
        # Tier two
        BURSARY_TIER_ENUMS[:tier_two] => { entity_id: "66671547-33ff-eb11-94ef-00224899ca99" },
        # Tier three
        BURSARY_TIER_ENUMS[:tier_three] => { entity_id: "c5521159-33ff-eb11-94ef-00224899ca99" },
      }.freeze
    end
  end
end
