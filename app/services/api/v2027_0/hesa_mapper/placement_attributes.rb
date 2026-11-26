# frozen_string_literal: true

module Api
  module V20270
    module HesaMapper
      class PlacementAttributes < Api::V20261::HesaMapper::PlacementAttributes
      private

        # Placements sent with a trainee keep their postcode and address, as
        # they do when sent to the placements endpoint.
        def mapped_params
          super.merge(@params.to_h.symbolize_keys.slice(:postcode, *Api::V20270::PlacementAttributes::ADDRESS_ATTRIBUTES))
        end
      end
    end
  end
end
