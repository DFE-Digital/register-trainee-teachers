# frozen_string_literal: true

module Hesa
  module CodeSets
    module BursaryLevels
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/burslev
      # Note that Tier 1, Tier 2, and Tier 3 are fetched from the previous year, i.e:
      # https://www.hesa.ac.uk/collection/c20053/e/burslev
      SCHOLARSHIP = "4"
      NONE = "6"
      TIER_ONE = "7"
      TIER_TWO = "8"
      TIER_THREE = "9"
      UNDERGRADUATE_BURSARY = "B"
      VETERAN_TEACHING_UNDERGRADUATE_BURSARY = "C"
      POSTGRADUATE_BURSARY = "D"
      GRANT = "E"

      MAPPING = {
        SCHOLARSHIP => ::CodeSets::BursaryDetails::SCHOLARSHIP,
        NONE => ::CodeSets::BursaryDetails::NO_BURSARY_AWARDED,
        TIER_ONE => ::CodeSets::BursaryDetails::NEW_TIER_ONE_BURSARY,
        TIER_TWO => ::CodeSets::BursaryDetails::NEW_TIER_TWO_BURSARY,
        TIER_THREE => ::CodeSets::BursaryDetails::NEW_TIER_THREE_BURSARY,
        UNDERGRADUATE_BURSARY => ::CodeSets::BursaryDetails::UNDERGRADUATE_BURSARY,
        VETERAN_TEACHING_UNDERGRADUATE_BURSARY => ::CodeSets::BursaryDetails::VETERAN_TEACHING_UNDERGRADUATE_BURSARY,
        POSTGRADUATE_BURSARY => ::CodeSets::BursaryDetails::POSTGRADUATE_BURSARY,
        GRANT => ::CodeSets::BursaryDetails::GRANT,
      }.freeze

      VALUES = {
        SCHOLARSHIP => "Scholarship",
        NONE => "No bursary, scholarship or grant awarded",
        TIER_ONE => "Tier 1",
        TIER_TWO => "Tier 2",
        TIER_THREE => "Tier 3",
        UNDERGRADUATE_BURSARY => "Undergraduate bursary",
        VETERAN_TEACHING_UNDERGRADUATE_BURSARY => "Veteran Teaching undergraduate bursary",
        POSTGRADUATE_BURSARY => "Postgraduate bursary",
        GRANT => "Grant",
      }.freeze
    end
  end
end
