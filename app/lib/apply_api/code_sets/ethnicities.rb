# frozen_string_literal: true

module ApplyApi
  module CodeSets
    module Ethnicities
      MAPPING = {
        "Asian or Asian British" => Diversities::ETHNIC_GROUP_ENUMS[:asian],
        "Black, African, Black British or Caribbean" => Diversities::ETHNIC_GROUP_ENUMS[:black],
        "Mixed or multiple ethnic groups" => Diversities::ETHNIC_GROUP_ENUMS[:mixed],
        "White" => Diversities::ETHNIC_GROUP_ENUMS[:white],
        "Another ethnic group" => Diversities::ETHNIC_GROUP_ENUMS[:other],
      }.freeze
    end
  end
end
