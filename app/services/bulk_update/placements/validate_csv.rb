# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ValidateCsv
      def initialize(csv:, record:)
        @csv = csv
        @record = record
      end

      def validate!
        header_row!
      end

    private

      attr_reader :csv, :record

      def header_row!
        return if expected_headers.to_set == csv_headers.to_set

        record.errors.add(:file, :invalid_header, headers: Reports::BulkPlacementReport::HEADERS.join(", "))
      end

      def expected_headers
        @expected_headers ||= Reports::BulkPlacementReport::HEADERS.map(&:downcase)
      end

      def csv_headers
        @csv_headers ||= csv.headers
      end
    end
  end
end
