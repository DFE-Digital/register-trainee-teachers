# frozen_string_literal: true

module Dttp
  module CodeSets
    YORKSHIRE_AND_HUMBER_DTTP_ID = "6a4b1c3c-f272-e711-80d3-005056ac45bb"

    module Regions
      MAPPING = {
        "North East" => { entity_id: "664b1c3c-f272-e711-80d3-005056ac45bb" },
        "North West" => { entity_id: "684b1c3c-f272-e711-80d3-005056ac45bb" },
        "Yorkshire and the Humber" => { entity_id: YORKSHIRE_AND_HUMBER_DTTP_ID },
        "Yorkshire and Humber" => { entity_id: YORKSHIRE_AND_HUMBER_DTTP_ID },
        "East Midlands" => { entity_id: "6c4b1c3c-f272-e711-80d3-005056ac45bb" },
        "West Midlands" => { entity_id: "6e4b1c3c-f272-e711-80d3-005056ac45bb" },
        "East of England" => { entity_id: "704b1c3c-f272-e711-80d3-005056ac45bb" },
        "London" => { entity_id: "724b1c3c-f272-e711-80d3-005056ac45bb" },
        "South East" => { entity_id: "744b1c3c-f272-e711-80d3-005056ac45bb" },
        "South West" => { entity_id: "764b1c3c-f272-e711-80d3-005056ac45bb" },
        "Wales (pseudo)" => { entity_id: "784b1c3c-f272-e711-80d3-005056ac45bb" },
        "Not Applicable" => { entity_id: "7a4b1c3c-f272-e711-80d3-005056ac45bb" },
        "South East and South Coast" => { entity_id: "66e38dc4-404a-e811-80f2-005056ac45bb" },
        "Non-regional providers" => { entity_id: "b2d8c5bb-424e-e811-80f3-005056ac45bb" },
        "South Coast" => { entity_id: "1ff128c9-424e-e811-80f3-005056ac45bb" },
      }.freeze
    end
  end
end
