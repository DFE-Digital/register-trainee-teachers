# frozen_string_literal: true

module PlacementSerializer
  class V01
    EXCLUDE_ATTRIBUTES = %w[
      id
      slug
      trainee_id
    ].freeze

    def initialize(placement)
      @placement = placement
    end

    def as_hash
      @placement.attributes.except(*EXCLUDE_ATTRIBUTES).merge(placement_id: @placement.slug)
    end
  end
end
