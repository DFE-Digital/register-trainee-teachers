# frozen_string_literal: true

module Hesa
  module CodeSets
    module Ethnicities
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "180"	=> Diversities::ARAB,
        "100"	=> Diversities::BANGLADESHI,
        "101"	=> Diversities::CHINESE,
        "103"	=> Diversities::INDIAN,
        "104"	=> Diversities::PAKISTANI,
        "119"	=> Diversities::ANOTHER_ASIAN_BACKGROUND,
        "120"	=> Diversities::AFRICAN,
        "121"	=> Diversities::CARIBBEAN,
        "139"	=> Diversities::ANOTHER_BLACK_BACKGROUND,
        "140"	=> Diversities::ASIAN_AND_WHITE,
        "141"	=> Diversities::BLACK_AFRICAN_AND_WHITE,
        "142"	=> Diversities::BLACK_CARIBBEAN_AND_WHITE,
        "159"	=> Diversities::ANOTHER_MIXED_BACKGROUND,
        "160"	=> Diversities::WHITE_BRITISH,
        "163"	=> Diversities::TRAVELLER_OR_GYPSY,
        "166"	=> Diversities::IRISH,
        "168"	=> Diversities::ROMA,
        "179"	=> Diversities::ANOTHER_WHITE_BACKGROUND,
        "899"	=> Diversities::ANOTHER_ETHNIC_BACKGROUND,
        "997"	=> Diversities::NOT_PROVIDED,
        "998"	=> Diversities::NOT_PROVIDED,
        "999"	=> Diversities::NOT_PROVIDED,
      }.freeze
    end
  end
end
