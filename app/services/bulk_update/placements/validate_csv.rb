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
        return if all_mandatory_headers? && no_extra_headers?

        record.errors.add(:file, :invalid_header, headers: Reports::BulkPlacementReport::HEADERS.join(", "))
      end

      def expected_headers
        @expected_headers ||= Reports::BulkPlacementReport::HEADERS.map(&:downcase)
      end

      def optional_headers
        @optional_headers ||= Reports::BulkPlacementReport::OPTIONAL_HEADERS.map(&:downcase)
      end

      def csv_headers
        @csv_headers ||= csv.headers
      end

      def all_mandatory_headers?
        (expected_headers - csv_headers).empty?
      end

      def no_extra_headers?
        (csv_headers - expected_headers - optional_headers).empty?
      end
    end
  end
end
