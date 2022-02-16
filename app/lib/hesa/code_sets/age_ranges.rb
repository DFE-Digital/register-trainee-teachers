# frozen_string_literal: true

module Hesa
  module CodeSets
    module AgeRanges
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/ittphsc
      MAPPING = {
        # "31" => "Further education",
        # "49" => "Other",
        "71" => AgeRange::THREE_TO_SEVEN,
        "73" => AgeRange::THREE_TO_NINE,
        "74" => AgeRange::THREE_TO_ELEVEN,
        "75" => AgeRange::FIVE_TO_NINE,
        "76" => AgeRange::FIVE_TO_ELEVEN,
        "77" => AgeRange::SEVEN_TO_ELEVEN,
        "78" => AgeRange::SEVEN_TO_FOURTEEN,
        "79" => AgeRange::NINE_TO_FOURTEEN,
        "80" => AgeRange::ELEVEN_TO_SIXTEEN,
        "81" => AgeRange::ELEVEN_TO_NINETEEN,
      }.freeze
    end
  end
end
