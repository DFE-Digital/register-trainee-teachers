# frozen_string_literal: true

module Hesa
  module CodeSets
    module Disabilities
      # https://www.hesa.ac.uk/collection/c21053/xml/c21053/c21053codelists.xsd
      MAPPING = {
        "00" => Diversities::NO_KNOWN_DISABILITY,
        "08" => Diversities::MULTIPLE_DISABILITIES,
        "51" => Diversities::LEARNING_DIFFICULTY,
        "53" => Diversities::SOCIAL_IMPAIRMENT,
        "54" => Diversities::LONG_STANDING_ILLNESS,
        "55" => Diversities::MENTAL_HEALTH_CONDITION,
        "56" => Diversities::PHYSICAL_DISABILITY,
        "57" => Diversities::DEAF,
        "58" => Diversities::BLIND,
        "96" => Diversities::OTHER,
      }.freeze
    end
  end
end
