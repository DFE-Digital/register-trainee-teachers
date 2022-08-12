# frozen_string_literal: true

module Hesa
  module CodeSets
    module Disabilities
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "95" =>	Diversities::NO_KNOWN_DISABILITY,
        "58" =>	Diversities::BLIND,
        "57" =>	Diversities::DEAF,
        "59" =>	"Development condition that you have had since childhood which affects motor, cognitive, social and emotional skills, and speech and language",
        "51" =>	Diversities::LEARNING_DIFFICULTY,
        "54" =>	Diversities::LONG_STANDING_ILLNESS,
        "55" =>	Diversities::MENTAL_HEALTH_CONDITION,
        "56" =>	Diversities::PHYSICAL_DISABILITY,
        "53" =>	Diversities::SOCIAL_IMPAIRMENT,
        "96" =>	Diversities::OTHER,
        "98" =>	"Prefer not to say",
        "99" =>	Diversities::NOT_PROVIDED,
      }.freeze
    end
  end
end
