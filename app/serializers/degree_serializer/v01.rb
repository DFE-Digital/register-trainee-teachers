# frozen_string_literal: true

module DegreeSerializer
  class V01
    EXCLUDED_ATTRIBUTES = %w[
      id
      slug
      trainee_id
      dttp_id
      locale_code
    ].freeze

    def initialize(degree)
      @degree = degree
    end

    def as_hash
      @degree.attributes.except(*EXCLUDED_ATTRIBUTES).merge(degree_id: @degree.slug)
    end
  end
end
