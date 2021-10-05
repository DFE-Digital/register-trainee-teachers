# frozen_string_literal: true

module HPITT
  module CodeSets
    module Disabilities
      MAPPING = {
        # Normalised from
        # Learning difficulty\n(for example, dyslexia, dyspraxia or ADHD)
        # by using `.gsub(/[^a-z]/i, "").downcase`
        "learningdifficultyforexampledyslexiadyspraxiaoradhd" => Diversities::LEARNING_DIFFICULTY,
        "deaforaserioushearingimpairment" => Diversities::DEAF,
        "other" => Diversities::OTHER,
        "notprovided" => Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
      }.freeze
    end
  end
end
