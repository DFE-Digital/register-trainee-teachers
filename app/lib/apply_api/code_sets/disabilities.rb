# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Disabilities
      OLD_MAPPING = {
        "blind" => ::Diversities::BLIND,
        "deaf" => ::Diversities::DEAF,
        "learning" => ::Diversities::LEARNING_DIFFICULTY,
        "long_standing" => ::Diversities::LONG_STANDING_ILLNESS,
        "mental" => ::Diversities::MENTAL_HEALTH_CONDITION,
        "physical" => ::Diversities::PHYSICAL_DISABILITY,
        "social" => ::Diversities::SOCIAL_IMPAIRMENT,
        "other" => ::Diversities::OTHER,
      }.freeze

      NEW_MAPPING = {
        "Blindness or a visual impairment not corrected by glasses" => ::Diversities::BLIND,
        "Deafness or a serious hearing impairment" => ::Diversities::DEAF,
        "Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference" => ::Diversities::LEARNING_DIFFICULTY,
        "Long-term illness" => ::Diversities::LONG_STANDING_ILLNESS,
        "Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood" => ::Diversities::DEVELOPMENT_CONDITION,
        "Mental health condition" => ::Diversities::MENTAL_HEALTH_CONDITION,
        "Physical disability or mobility issue" => ::Diversities::PHYSICAL_DISABILITY,
        "Autistic spectrum condition or another condition affecting speech, language, communication or social skills" => ::Diversities::SOCIAL_IMPAIRMENT,
        "I do not have any of these disabilities or health conditions" => ::Diversities::NO_KNOWN_DISABILITY,
        "Prefer not to say" => ::Diversities::PREFER_NOT_TO_SAY,
      }.freeze
    end
  end
end
