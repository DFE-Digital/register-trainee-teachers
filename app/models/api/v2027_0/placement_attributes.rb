# frozen_string_literal: true

module Api
  module V20270
    class PlacementAttributes < Api::V20261::PlacementAttributes
      # A school or setting that is not in the schools list can be sent with
      # its address. The lines are saved together in the placement's `address`.
      ADDRESS_ATTRIBUTES = Placement::ADDRESS_LINE_FIELDS
      ADDRESS_MAX_LENGTH = 255

      ATTRIBUTES = (Api::V20261::PlacementAttributes::ATTRIBUTES + ADDRESS_ATTRIBUTES).freeze
      ADDRESS_ATTRIBUTES.each { |attr| attribute(attr) }

      validates(*ADDRESS_ATTRIBUTES, length: { maximum: ADDRESS_MAX_LENGTH })

      def self.from_placement(placement)
        super.tap do |placement_attributes|
          lines = Placement.split_address(placement.address)
          ADDRESS_ATTRIBUTES.each_with_index do |attr, index|
            placement_attributes.public_send(:"#{attr}=", lines[index].presence)
          end
        end
      end

      def assign_attributes(new_attributes)
        super
        clear_address if school_id.present?
      end

      def attributes
        lines = ADDRESS_ATTRIBUTES.map { |attr| public_send(attr) }

        super.except(*ADDRESS_ATTRIBUTES.map(&:to_s)).merge("address" => Placement.address_from_lines(*lines))
      end

    private

      def clear_address
        ADDRESS_ATTRIBUTES.each { |attr| public_send(:"#{attr}=", nil) }
      end
    end
  end
end
