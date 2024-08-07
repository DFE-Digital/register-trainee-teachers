# frozen_string_literal: true

module Api
  module V01
    class PlacementSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        slug
        trainee_id
        school_id
        address
      ].freeze

      def initialize(placement)
        @placement = placement
      end

      def as_hash
        @placement.attributes.except(*EXCLUDED_ATTRIBUTES).merge(
          placement_id: @placement.slug,
          **school_attributes,
        )
      end

    private

      def school_attributes
        return {} if @placement.school.blank?

        {
          urn: @placement.school.urn,
          name: @placement.school.name,
          postcode: @placement.school.postcode,
        }
      end
    end
  end
end
