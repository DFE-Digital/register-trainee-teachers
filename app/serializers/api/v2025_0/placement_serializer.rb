# frozen_string_literal: true

module Api
  module V20250
    class PlacementSerializer
      EXCLUDED_ATTRIBUTES = %w[
        id
        slug
        trainee_id
        school_id
      ].freeze

      attr_reader :placement

      def initialize(placement)
        @placement = placement
      end

      def as_hash
        placement
          .as_json(except: EXCLUDED_ATTRIBUTES)
          .merge(school_attributes)
      end

    private

      def school_attributes
        {
          "placement_id" => placement.slug,
          "address" => placement.full_address,
        }
      end
    end
  end
end
