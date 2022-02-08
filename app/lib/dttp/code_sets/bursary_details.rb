# frozen_string_literal: true

module Dttp
  module CodeSets
    module BursaryDetails
      NO_BURSARY_AWARDED = "1c8375c2-7722-e711-80c8-0050568902d3"

      POSTGRADUATE_BURSARY = "8c629dd7-bfc3-eb11-bacc-000d3addca7a"
      UNDERGRADUATE_BURSARY = "96756cc6-6041-e811-80f2-005056ac45bb"
      SCHOOL_DIRECT_SALARIED = "3036b79f-9fc7-eb11-bacc-000d3ab7dcfe"
      EARLY_YEARS_SALARIED = "fd403c13-3e07-ec11-94ef-000d3adda801"

      SCHOLARSHIP = "188375c2-7722-e711-80c8-0050568902d3"

      NEW_TIER_ONE_BURSARY = "001bf834-33ff-eb11-94ef-00224899ca99"
      NEW_TIER_TWO_BURSARY = "66671547-33ff-eb11-94ef-00224899ca99"
      NEW_TIER_THREE_BURSARY = "c5521159-33ff-eb11-94ef-00224899ca99"

      OLD_TIER_ONE_BURSARY = "1e8375c2-7722-e711-80c8-0050568902d3"
      OLD_TIER_TWO_BURSARY = "208375c2-7722-e711-80c8-0050568902d3"
      OLD_TIER_THREE_BURSARY = "228375c2-7722-e711-80c8-0050568902d3"

      BURSARIES = [
        POSTGRADUATE_BURSARY,
        UNDERGRADUATE_BURSARY,
        OLD_TIER_ONE_BURSARY,
        OLD_TIER_TWO_BURSARY,
        OLD_TIER_THREE_BURSARY,
      ].freeze

      NEW_TIERS = [
        NEW_TIER_ONE_BURSARY,
        NEW_TIER_TWO_BURSARY,
        NEW_TIER_THREE_BURSARY,
      ].freeze

      GRANTS = [
        EARLY_YEARS_SALARIED,
        SCHOOL_DIRECT_SALARIED,
      ].freeze

      MAPPING = {
        # Postgraduate bursary
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => { entity_id: POSTGRADUATE_BURSARY },
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => { entity_id: POSTGRADUATE_BURSARY },
        # Undergraduate bursary
        TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => { entity_id: UNDERGRADUATE_BURSARY },
        TRAINING_ROUTE_ENUMS[:opt_in_undergrad] => { entity_id: UNDERGRADUATE_BURSARY },
        # Grants
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => { entity_id: EARLY_YEARS_SALARIED },
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => { entity_id: SCHOOL_DIRECT_SALARIED },
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => { entity_id: SCHOOL_DIRECT_SALARIED },
        # Tier one
        BURSARY_TIER_ENUMS[:tier_one] => { entity_id: NEW_TIER_ONE_BURSARY },
        # Tier two
        BURSARY_TIER_ENUMS[:tier_two] => { entity_id: NEW_TIER_TWO_BURSARY },
        # Tier three
        BURSARY_TIER_ENUMS[:tier_three] => { entity_id: NEW_TIER_THREE_BURSARY },
      }.freeze
    end
  end
end
