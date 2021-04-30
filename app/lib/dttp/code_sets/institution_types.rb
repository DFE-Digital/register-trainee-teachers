# frozen_string_literal: true

module Dttp
  module CodeSets
    module InstitutionTypes
      MAPPING = {
        "EBITT" => { entity_id: "b5ec33aa-216d-e711-80d2-005056ac45bb" },
        "EYITT" => { entity_id: "b7ec33aa-216d-e711-80d2-005056ac45bb" },
        "HEI" => { entity_id: "b9ec33aa-216d-e711-80d2-005056ac45bb" },
        "ITT Provider - HESA" => { entity_id: "bbec33aa-216d-e711-80d2-005056ac45bb" },
        "ITT Provider - Non-HESA" => { entity_id: "bdec33aa-216d-e711-80d2-005056ac45bb" },
        "NonHEI (data gathered under Scitt process)" => { entity_id: "bfec33aa-216d-e711-80d2-005056ac45bb" },
        "Non-HESA HEI" => { entity_id: "c1ec33aa-216d-e711-80d2-005056ac45bb" },
        "SCITT" => { entity_id: "cdec33aa-216d-e711-80d2-005056ac45bb" },
      }.freeze
    end
  end
end
