# frozen_string_literal: true

module Hesa
  module CodeSets
    module BursaryLevels
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/burslev
      MAPPING = {
        "4" => Dttp::CodeSets::BursaryDetails::SCHOLARSHIP,
        "6" => Dttp::CodeSets::BursaryDetails::NO_BURSARY_AWARDED,
        "B" => Dttp::CodeSets::BursaryDetails::UNDERGRADUATE_BURSARY,
        "C" => Dttp::CodeSets::BursaryDetails::SERVICE_LEAVER_BURSARY,
        "D" => Dttp::CodeSets::BursaryDetails::POSTGRADUATE_BURSARY,
      }.freeze
    end
  end
end
