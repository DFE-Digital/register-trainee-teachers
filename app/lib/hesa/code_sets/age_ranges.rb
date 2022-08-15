# frozen_string_literal: true

module Hesa
  module CodeSets
    module AgeRanges
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/ittphsc
      MAPPING = {
        "13909"	=> AgeRange::THREE_TO_SEVEN,
        "13911"	=> AgeRange::THREE_TO_NINE,
        "13912"	=> AgeRange::THREE_TO_ELEVEN,
        "13913"	=> AgeRange::FIVE_TO_NINE,
        "13914"	=> AgeRange::FIVE_TO_ELEVEN,
        "13915"	=> AgeRange::SEVEN_TO_ELEVEN,
        "13916"	=> AgeRange::SEVEN_TO_FOURTEEN,
        "13917" => AgeRange::NINE_TO_FOURTEEN,
        "13918"	=> AgeRange::ELEVEN_TO_SIXTEEN,
        "13919"	=> AgeRange::ELEVEN_TO_NINETEEN,
        # "99803"	=> "Teacher training qualification: Other"
        # "99801"	=> "Teacher training qualification: Further education/Higher education"
      }.freeze
    end
  end
end
