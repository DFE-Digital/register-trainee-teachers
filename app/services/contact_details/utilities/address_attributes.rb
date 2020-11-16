module ContactDetails
  module Utilities
    class AddressAttributes
      def initialize(attributes)
        @attributes = attributes
      end

      def attributes
        uk_locale? ? @attributes.merge(reset_non_uk_attributes) : @attributes.merge(reset_uk_attributes)
      end

    private

      def uk_locale?
        @attributes[:locale_code] == "uk"
      end

      def reset_uk_attributes
        { address_line_one: nil, address_line_two: nil, town_city: nil, postcode: nil }
      end

      def reset_non_uk_attributes
        { international_address: nil }
      end
    end
  end
end
