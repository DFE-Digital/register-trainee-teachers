# frozen_string_literal: true

module Dttp
  module CodeSets
    module Ethnicities
      AFRICAN = "Black or Black British - African"
      ARAB = "Arab"
      BANGLADESHI = "Asian or Asian British - Bangladeshi"
      CARIBBEAN = "Black or Black British - Caribbean"
      CHINESE = "Chinese"
      GYPSY_OR_TRAVELLER = "Gypsy or Traveller"
      INDIAN = "Asian or Asian British - Indian"
      INFORMATION_NOT_SAUGHT = "Information not yet sought"
      INFORMATION_REFUSED = "Information refused"
      IRISH_TRAVELLER = "Irish traveller"
      NOT_KNOWN = "Not known"
      OTHER_ASIAN = "Other Asian background"
      OTHER_BLACK = "Other Black background"
      OTHER_ETHNIC = "Other Ethnic background"
      OTHER_MIXED = "Other Mixed background"
      OTHER_WHITE = "Other White background"
      PAKISTANI = "Asian or Asian British - Pakistani"
      WHITE = "White"
      WHITE_AND_ASIAN = "Mixed - White and Asian"
      WHITE_AND_BLACK_AFRICAN = "Mixed - White and Black African"
      WHITE_AND_BLACK_CARIBBEAN = "Mixed - White and Black Caribbean"
      WHITE_BRITISH = "White - British"
      WHITE_IRISH = "White - Irish"
      WHITE_SCOTTISH = "White - Scottish"

      MAPPING = [
        { name: ARAB, code: 50, ethnic_minority: true },
        { name: BANGLADESHI, code: 33, ethnic_minority: true },
        { name: INDIAN, code: 31, ethnic_minority: true },
        { name: PAKISTANI, code: 32, ethnic_minority: true },
        { name: AFRICAN, code: 22, ethnic_minority: true },
        { name: CARIBBEAN, code: 21, ethnic_minority: true },
        { name: CHINESE, code: 34, ethnic_minority: true },
        { name: GYPSY_OR_TRAVELLER, code: 15, ethnic_minority: false },
        { name: INFORMATION_NOT_SAUGHT, code: 99, ethnic_minority: false },
        { name: INFORMATION_REFUSED, code: 98, ethnic_minority: false },
        { name: IRISH_TRAVELLER, code: 14, ethnic_minority: false },
        { name: WHITE_AND_ASIAN, code: 43, ethnic_minority: true },
        { name: WHITE_AND_BLACK_AFRICAN, code: 42, ethnic_minority: true },
        { name: WHITE_AND_BLACK_CARIBBEAN, code: 41, ethnic_minority: true },
        { name: NOT_KNOWN, code: 90, ethnic_minority: false },
        { name: OTHER_ASIAN, code: 39, ethnic_minority: true },
        { name: OTHER_BLACK, code: 29, ethnic_minority: true },
        { name: OTHER_ETHNIC, code: 80, ethnic_minority: true },
        { name: OTHER_MIXED, code: 49, ethnic_minority: true },
        { name: OTHER_WHITE, code: 19, ethnic_minority: false },
        { name: WHITE, code: 10, ethnic_minority: false },
        { name: WHITE_BRITISH, code: 11, ethnic_minority: false },
        { name: WHITE_IRISH, code: 12, ethnic_minority: false },
        { name: WHITE_SCOTTISH, code: 13, ethnic_minority: false },
      ].freeze
    end
  end
end
