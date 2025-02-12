# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ValidateCsv
      def initialize(csv:, record:)
        @csv = csv
        @record = record
      end

      def validate!
        header_row!
        trainees!
      end

    private

      attr_reader :csv, :record

      def header_row!
        return if headers.all? { |value| value.is_a?(String) } &&
          headers.sort == BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.sort

        record.errors.add(:file, :invalid_headers, headers: BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys.join(", "))
      end

      def trainees!
        return unless rows.empty?

        record.errors.add(:file, :no_trainees)
      end

      def headers
        @headers ||= csv.headers - ["Errors"]
      end

      def rows
        @rows ||= csv.entries.reject { |entry| entry.to_h.values.all?(&:blank?) }
      end
    end
  end
end
