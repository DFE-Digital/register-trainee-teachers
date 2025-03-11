# frozen_string_literal: true

module Hesa
  module CodeSets
    module Disabilities
      # https://www.hesa.ac.uk/collection/c22053/xml/c22053/c22053codelists.xsd
      MAPPING = {
        "95" =>	Diversities::NO_KNOWN_DISABILITY,
        "58" =>	Diversities::BLIND,
        "57" =>	Diversities::DEAF,
        "59" =>	Diversities::DEVELOPMENT_CONDITION,
        "51" =>	Diversities::LEARNING_DIFFICULTY,
        "54" =>	Diversities::LONG_STANDING_ILLNESS,
        "55" =>	Diversities::MENTAL_HEALTH_CONDITION,
        "56" =>	Diversities::PHYSICAL_DISABILITY,
        "53" =>	Diversities::SOCIAL_IMPAIRMENT,
        "96" =>	Diversities::OTHER,
        # HESA distinguishes between (in order) 'Prefer not to say' and
        # 'Not available'. We consider these equivalent in Register.
        "98" =>	Diversities::NOT_PROVIDED,
        "99" =>	Diversities::NOT_PROVIDED,
      }.freeze

      NAME_MAPPING = {
        "No disabilities" => Diversities::NO_KNOWN_DISABILITY,
        "Not provided" =>	Diversities::NOT_PROVIDED,
        "Has disabilities but specific disabilities not shared" => Diversities::OTHER,
        "Blind" => Diversities::BLIND,
        "Deaf" =>	Diversities::DEAF,
        "Learning difficulty" => Diversities::LEARNING_DIFFICULTY,
        "Long-standing illness" => Diversities::LONG_STANDING_ILLNESS,
        "Mental health condition" => Diversities::MENTAL_HEALTH_CONDITION,
        "Other" => Diversities::OTHER,
        "Physical disability or mobility issue" => Diversities::PHYSICAL_DISABILITY,
        "Social or communication impairment" => Diversities::SOCIAL_IMPAIRMENT,
        "Development condition" => Diversities::DEVELOPMENT_CONDITION,
      }.freeze
    end
  end
end
