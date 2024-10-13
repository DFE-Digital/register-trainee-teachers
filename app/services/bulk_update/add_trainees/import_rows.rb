# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRows
      include ServicePattern

      attr_reader :id

      def initialize(id:)
        self.id = id
      end

      def call
        # TODO: Read the uploaded file content from the DB

        # TODO: Parse the CSV

        # TODO: Begin a transaction

        # TODO: Process each row

        # TODO: Commit or rollback the transaction depending on whether all rows were error free
      end
    end
  end
end
