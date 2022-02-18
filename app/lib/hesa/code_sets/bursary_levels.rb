# frozen_string_literal: true

module Hesa
  module CodeSets
    module BursaryLevels
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      # https://www.hesa.ac.uk/collection/c21053/e/burslev
      # Note that Tier 1, Tier 2, and Tier 3 are fetched from the previous year, i.e:
      # https://www.hesa.ac.uk/collection/c20053/e/burslev
      MAPPING = {
        "4" => Dttp::CodeSets::BursaryDetails::SCHOLARSHIP,
        "6" => Dttp::CodeSets::BursaryDetails::NO_BURSARY_AWARDED,
        "7" => Dttp::CodeSets::BursaryDetails::NEW_TIER_ONE_BURSARY,
        "8" => Dttp::CodeSets::BursaryDetails::NEW_TIER_TWO_BURSARY,
        "9" => Dttp::CodeSets::BursaryDetails::NEW_TIER_THREE_BURSARY,
        "B" => Dttp::CodeSets::BursaryDetails::UNDERGRADUATE_BURSARY,
        "C" => Dttp::CodeSets::BursaryDetails::SERVICE_LEAVER_BURSARY,
        "D" => Dttp::CodeSets::BursaryDetails::POSTGRADUATE_BURSARY,
      }.freeze
    end
  end
end
