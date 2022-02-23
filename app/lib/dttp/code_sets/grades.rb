# frozen_string_literal: true

module Dttp
  module CodeSets
    module Grades
      # Do not make any changes to the keys. If necessary, change Degree#grade to enum type first
      FIRST_CLASS_HONOURS = "First-class honours"
      UPPER_SECOND_CLASS_HONOURS = "Upper second-class honours (2:1)"
      LOWER_SECOND_CLASS_HONOURS = "Lower second-class honours (2:2)"
      THIRD_CLASS_HONOURS = "Third-class honours"
      PASS = "Pass"
      OTHER = "Other"

      MAPPING = {
        FIRST_CLASS_HONOURS => {
          entity_id: "fe2fca5f-766d-e711-80d2-005056ac45bb",
          hesa_code: "01",
        },
        UPPER_SECOND_CLASS_HONOURS => {
          entity_id: "0030ca5f-766d-e711-80d2-005056ac45bb",
          hesa_code: "02",
        },
        LOWER_SECOND_CLASS_HONOURS => {
          entity_id: "0230ca5f-766d-e711-80d2-005056ac45bb",
          hesa_code: "03",
        },
        THIRD_CLASS_HONOURS => {
          entity_id: "0630ca5f-766d-e711-80d2-005056ac45bb",
          hesa_code: "05",
        },
        PASS => {
          entity_id: "0e30ca5f-766d-e711-80d2-005056ac45bb",
          hesa_code: "14",
        },
        OTHER => { entity_id: "1c30ca5f-766d-e711-80d2-005056ac45bb" },
      }.freeze
    end
  end
end
