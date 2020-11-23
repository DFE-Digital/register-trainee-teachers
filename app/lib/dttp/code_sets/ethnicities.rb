# frozen_string_literal: true

module Dttp
  module CodeSets
    module Ethnicities
      MAPPING = {
        ::Diversities::AFRICAN => { hesa_code: 22, ethnic_minority: true, entity_id: "c00bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ANOTHER_ASIAN_BACKGROUND => { hesa_code: 39, ethnic_minority: true, entity_id: "cc0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ANOTHER_BLACK_BACKGROUND => { hesa_code: 29, ethnic_minority: true, entity_id: "c20bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ANOTHER_ETHNIC_BACKGROUND => { hesa_code: 80, ethnic_minority: true, entity_id: "d80bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ANOTHER_MIXED_BACKGROUND => { hesa_code: 49, ethnic_minority: true, entity_id: "d40bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ANOTHER_WHITE_BACKGROUND => { hesa_code: 19, ethnic_minority: false, entity_id: "bc0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ARAB => { hesa_code: 50, ethnic_minority: true, entity_id: "d60bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::ASIAN_AND_WHITE => { hesa_code: 43, ethnic_minority: true, entity_id: "d20bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::BANGLADESHI => { hesa_code: 33, ethnic_minority: true, entity_id: "c80bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::BLACK_AFRICAN_AND_WHITE => { hesa_code: 42, ethnic_minority: true, entity_id: "d00bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::BLACK_CARIBBEAN_AND_WHITE => { hesa_code: 41, ethnic_minority: true, entity_id: "ce0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::CARIBBEAN => { hesa_code: 21, ethnic_minority: true, entity_id: "be0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::CHINESE => { hesa_code: 34, ethnic_minority: true, entity_id: "ca0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::INDIAN => { hesa_code: 31, ethnic_minority: true, entity_id: "c40bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::IRISH => { hesa_code: 12, ethnic_minority: false, entity_id: "b40bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::NOT_PROVIDED => { hesa_code: 90, ethnic_minority: false, entity_id: "da0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::PAKISTANI => { hesa_code: 32, ethnic_minority: true, entity_id: "c60bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::TRAVELLER_OR_GYPSY => { hesa_code: 15, ethnic_minority: false, entity_id: "ba0bb892-2b9d-e711-80d9-005056ac45bb" },
        ::Diversities::WHITE_BRITISH => { hesa_code: 11, ethnic_minority: false, entity_id: "b20bb892-2b9d-e711-80d9-005056ac45bb" },
      }.freeze
    end
  end
end
