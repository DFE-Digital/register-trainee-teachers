# frozen_string_literal: true

module HPITT
  module CodeSets
    module Ethnicities
      MAPPING = {
        # Normalised from
        # Asian or Asian British\n(includes any Asian background, for example, Bangladeshi, Chinese, Indian, Pakistani)
        # by using `.gsub(/[^a-z]/i, "").downcase`
        "asianorasianbritishincludesanyasianbackgroundforexamplebangladeshichineseindianpakistani" => Diversities::ETHNIC_GROUP_ENUMS[:asian],
        "anotherethnicgroupincludesanyotherethnicgroupforexamplearab" => Diversities::ETHNIC_GROUP_ENUMS[:other],
        "blackafricanblackbritishorcaribbeanincludesanyblackbackground" => Diversities::ETHNIC_GROUP_ENUMS[:black],
        "notprovided" => Diversities::ETHNIC_GROUP_ENUMS[:not_provided],
        "mixedormultipleethnicgroupsincludesanymixedbackground" => Diversities::ETHNIC_GROUP_ENUMS[:mixed],
        "whiteincludesanywhitebackground" => Diversities::ETHNIC_GROUP_ENUMS[:white],
      }.freeze
    end
  end
end
