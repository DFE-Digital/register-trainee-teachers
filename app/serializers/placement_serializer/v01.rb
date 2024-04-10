# frozen_string_literal: true

module PlacementSerializer
  class V01
    EXCLUDED_ATTRIBUTES = %w[
      id
      slug
      trainee_id
      school_id
    ].freeze

    def initialize(placement)
      @placement = placement
    end

    def as_hash
      @placement.attributes.except(*EXCLUDED_ATTRIBUTES).merge(placement_id: @placement.slug)
    end
  end
end
