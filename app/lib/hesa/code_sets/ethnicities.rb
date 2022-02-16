# frozen_string_literal: true

module Hesa
  module CodeSets
    module Ethnicities
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      MAPPING = {
        "10" => Diversities::WHITE_BRITISH,
        "15" => Diversities::TRAVELLER_OR_GYPSY,
        "21" => Diversities::CARIBBEAN,
        "22" => Diversities::AFRICAN,
        "29" => Diversities::ANOTHER_BLACK_BACKGROUND,
        "31" => Diversities::INDIAN,
        "32" => Diversities::PAKISTANI,
        "33" => Diversities::BANGLADESHI,
        "34" => Diversities::CHINESE,
        "39" => Diversities::ANOTHER_ASIAN_BACKGROUND,
        "41" => Diversities::BLACK_CARIBBEAN_AND_WHITE,
        "42" => Diversities::BLACK_AFRICAN_AND_WHITE,
        "43" => Diversities::ASIAN_AND_WHITE,
        "49" => Diversities::ANOTHER_MIXED_BACKGROUND,
        "50" => Diversities::ARAB,
        "80" => Diversities::ANOTHER_ETHNIC_BACKGROUND,
        "90" => Diversities::NOT_PROVIDED,
        "98" => Diversities::INFORMATION_REFUSED,
      }.freeze
    end
  end
end
