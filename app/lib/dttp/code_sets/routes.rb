# frozen_string_literal: true

module Dttp
  module CodeSets
    module Routes
      MAPPING = {
        TRAINING_ROUTE_ENUMS[:assessment_only] => { entity_id: "99f435d5-a626-e711-80c8-0050568902d3" },
        TRAINING_ROUTE_ENUMS[:provider_led] => { entity_id: "6189922e-acc2-e611-80be-00155d010316" },
      }.freeze
    end
  end
end
