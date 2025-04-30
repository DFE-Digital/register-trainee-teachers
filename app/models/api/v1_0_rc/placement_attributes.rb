# frozen_string_literal: true

module Api
  module V10Rc
    class PlacementAttributes < Api::V01::PlacementAttributes
      include Api::ErrorAttributeAdapter
      attr_accessor :record_source

      def initialize(params, record_source: nil)
        super(params)
        self.record_source = record_source
      end
    end
  end
end
