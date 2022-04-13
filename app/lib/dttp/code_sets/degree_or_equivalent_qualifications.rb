# frozen_string_literal: true

module Dttp
  module CodeSets
    module DegreeOrEquivalentQualifications
      MAPPING = {
        "UK degree (England)" => { entity_id: "4769c562-756d-e711-80d2-005056ac45bb" },
        "UK degree (Scotland)" => { entity_id: "4969c562-756d-e711-80d2-005056ac45bb" },
        "UK degree (Wales)" => { entity_id: "4b69c562-756d-e711-80d2-005056ac45bb" },
        "UK degree (Northern Ireland)" => { entity_id: "4d69c562-756d-e711-80d2-005056ac45bb" },
        "Non-UK degree (other EU)" => { entity_id: "4f69c562-756d-e711-80d2-005056ac45bb" },
        "Non-UK degree (non EU)" => { entity_id: "5169c562-756d-e711-80d2-005056ac45bb" },
        "Degree equivalent" => { entity_id: "5369c562-756d-e711-80d2-005056ac45bb" },
      }.freeze
    end
  end
end
