# frozen_string_literal: true

module Api
  module V20270
    class PlacementSerializer < Api::V20261::PlacementSerializer
    private

      # The address lines as they were sent, for a school or setting that is
      # not in the schools list. `address` still gives the full address.
      def school_attributes
        lines = Placement.split_address(placement.address)

        super.merge(
          PlacementAttributes::ADDRESS_ATTRIBUTES.each_with_index.to_h do |attr, index|
            [attr.to_s, lines[index].presence]
          end,
        )
      end
    end
  end
end
