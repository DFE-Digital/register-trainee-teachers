# frozen_string_literal: true

module Hesa
  module CodeSets
    module Modes
      DORMANT_FULL_TIME = "Dormant - previously full-time"
      DORMANT_PART_TIME = "Dormant - previously part-time"

      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/mode
      MAPPING = {
        "01" => "Full-time according to funding council definitions",
        "02" => "Other full-time",
        "31" => "Part-time",
        "63" => DORMANT_FULL_TIME,
        "64" => DORMANT_PART_TIME,
      }.freeze
    end
  end
end
