# frozen_string_literal: true

module CodeSets
  module Disabilities
    MAPPING = {
      ::Diversities::BLIND => { entity_id: "e798eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::DEAF => { entity_id: "e598eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::LEARNING_DIFFICULTY => { entity_id: "d998eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::LONG_STANDING_ILLNESS => { entity_id: "df98eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::MENTAL_HEALTH_CONDITION => { entity_id: "e198eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::MULTIPLE_DISABILITIES => { entity_id: "d398eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::NOT_PROVIDED => { entity_id: "ef98eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::NO_KNOWN_DISABILITY => { entity_id: "c398eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::OTHER => { entity_id: "ef98eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::PHYSICAL_DISABILITY => { entity_id: "e398eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::SOCIAL_IMPAIRMENT => { entity_id: "dd98eae7-4ba5-e711-80da-005056ac45bb" },
      ::Diversities::DEVELOPMENT_CONDITION => { entity_id: "82e2ad24-5568-4e0b-a362-41666a668fb9" },
    }.freeze
  end
end
