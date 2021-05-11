# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Disabilities
      MAPPING = {
        "blind" => ::Diversities::BLIND,
        "deaf" => ::Diversities::DEAF,
        "learning" => ::Diversities::LEARNING_DIFFICULTY,
        "long_standing" => ::Diversities::LONG_STANDING_ILLNESS,
        "mental" => ::Diversities::MENTAL_HEALTH_CONDITION,
        "physical" => ::Diversities::PHYSICAL_DISABILITY,
        "social" => ::Diversities::SOCIAL_IMPAIRMENT,
        "other" => ::Diversities::OTHER,
      }.freeze
    end
  end
end
