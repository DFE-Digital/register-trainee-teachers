# frozen_string_literal: true

module Hesa
  module ReferenceData
    class V20261 < V20260
      TYPES = V20260::TYPES.merge(iqts_country: ::ReferenceData::COUNTRIES).freeze
    end
  end
end
