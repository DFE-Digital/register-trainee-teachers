# frozen_string_literal: true

module PlacementSerializer
  class V01
    def initialize(placment)
      @placment = placment
    end

    def as_hash
      @placment.attributes
    end
  end
end
