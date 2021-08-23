# frozen_string_literal: true

module Dttp
  module CodeSets
    module FundingBands
      MAPPING = {
        BURSARY_TIER_ENUMS[:tier_one] => { entity_id: "001bf834-33ff-eb11-94ef-00224899ca99" },
        BURSARY_TIER_ENUMS[:tier_two] => { entity_id: "66671547-33ff-eb11-94ef-00224899ca99" },
        BURSARY_TIER_ENUMS[:tier_three] => { entity_id: "c5521159-33ff-eb11-94ef-00224899ca99" },
      }.freeze
    end
  end
end
