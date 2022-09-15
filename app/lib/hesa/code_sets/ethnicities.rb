# frozen_string_literal: true

module Hesa
  module CodeSets
    module Ethnicities
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      # https://www.hesa.ac.uk/collection/c22053/e/ethnic
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
        # HESA distinguishes between (in order) 'Not known', 'Prefer not to say'
        # and 'Not available'. We consider these equivalent in Register.
        "997"	=> Diversities::NOT_PROVIDED,
        "998"	=> Diversities::NOT_PROVIDED,
        "999"	=> Diversities::NOT_PROVIDED,
      }.freeze

      NAME_MAPPING = {
        "Arab" => Diversities::ARAB,
        "Asian - Bangladeshi or Bangladeshi British" => Diversities::BANGLADESHI,
        "Asian - Chinese or Chinese British" => Diversities::CHINESE,
        "Asian - Indian or Indian British" => Diversities::INDIAN,
        "Asian - Pakistani or Pakistani British" => Diversities::PAKISTANI,
        "Any other Asian background" => Diversities::ANOTHER_ASIAN_BACKGROUND,
        "Black - African or African British" => Diversities::AFRICAN,
        "Black - Caribbean or Caribbean British" => Diversities::CARIBBEAN,
        "Any other Black background" => Diversities::ANOTHER_BLACK_BACKGROUND,
        "Mixed or multiple ethnic groups - White or White British and Asian or Asian British" => Diversities::ASIAN_AND_WHITE,
        "Mixed or multiple ethnic groups - White or White British and Black African or Black African British" => Diversities::BLACK_AFRICAN_AND_WHITE,
        "Mixed or multiple ethnic groups - White or White British and Black Caribbean or Black Caribbean British" => Diversities::BLACK_CARIBBEAN_AND_WHITE,
        "Any other Mixed or Multiple ethnic background" => Diversities::ANOTHER_MIXED_BACKGROUND,
        "White - English, Scottish, Welsh, Northern Irish or British" => Diversities::WHITE_BRITISH,
        "White - Gypsy or Irish Traveller" => Diversities::TRAVELLER_OR_GYPSY,
        "White - Irish" => Diversities::IRISH,
        "White - Roma" => Diversities::ROMA,
        "Any other White background" => Diversities::ANOTHER_WHITE_BACKGROUND,
        "Any other ethnic background" => Diversities::ANOTHER_ETHNIC_BACKGROUND,
        "Prefer not to say" => Diversities::NOT_PROVIDED,
        "Not available" => Diversities::NOT_PROVIDED,
      }.freeze
    end
  end
end
