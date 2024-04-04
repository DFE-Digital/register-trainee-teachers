module Api
  module MapHesaAttributes
    module Placements
      def initialize(placement)
        @placement = placement
      end

      def call
        {
          # Map the HESA attributes for the placement here
        }
      end
    end
  end
end
