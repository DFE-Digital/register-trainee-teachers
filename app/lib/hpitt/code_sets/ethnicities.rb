# frozen_string_literal: true

module HPITT
  module CodeSets
    module Ethnicities
      MAPPING = {
        "Asian or Asian British\n(includes any Asian background, for example, Bangladeshi, Chinese, Indian, Pakistani)" => Diversities::ETHNIC_GROUP_ENUMS[:asian],
        "Another ethnic group\n(includes any other ethnic group, for example, Arab)" => Diversities::ETHNIC_GROUP_ENUMS[:other],
        "Black, African, Black British or Caribbean\n(includes any Black background)" => Diversities::ETHNIC_GROUP_ENUMS[:black],
        "Not provided" => Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        "Mixed or multiple ethnic groups\n(includes any Mixed background)" => Diversities::ETHNIC_GROUP_ENUMS[:mixed],
        "White\n(includes any White background)" => Diversities::ETHNIC_GROUP_ENUMS[:white],
      }.freeze
    end
  end
end
