# frozen_string_literal: true

module Dttp
  module CodeSets
    module Grades
      MAPPING = {
        "First-class honours" => { entity_id: "fe2fca5f-766d-e711-80d2-005056ac45bb" },
        "Upper second-class honours (2:1)" => { entity_id: "0030ca5f-766d-e711-80d2-005056ac45bb" },
        "Lower second-class honours (2:2)" => { entity_id: "0230ca5f-766d-e711-80d2-005056ac45bb" },
        "Third-class honours" => { entity_id: "0630ca5f-766d-e711-80d2-005056ac45bb" },
        "Pass" => { entity_id: "0e30ca5f-766d-e711-80d2-005056ac45bb" },
        "Other" => { entity_id: "1c30ca5f-766d-e711-80d2-005056ac45bb" },
      }.freeze
    end
  end
end
