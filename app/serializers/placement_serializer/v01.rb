# frozen_string_literal: true

module PlacementSerializer
  class V01
    def initialize(placment)
      @placment = placment
    end

    def as_hash
      @placment.attributes.merge({
        school_urn: @placement.school.urn,
      })
    end
  end
end
