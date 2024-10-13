# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRow
      include ServicePattern

      attr_reader :id

      def initialize(attributes:)
        self.attributes = attributes
      end

      def call
        # TODO: Map the attributes to the correct fields

        # TODO: Save the record

        # TODO: Return the record or an error
      end
    end
  end
end
