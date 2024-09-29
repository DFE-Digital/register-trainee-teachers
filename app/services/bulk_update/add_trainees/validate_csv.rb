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
        return if headers.intersect?(all_headers)

        record.errors.add(:file, :no_header_detected)
      end

      def trainees!
        return unless csv.empty? || (rows.one? && not_a_trainee_row?)

        record.errors.add(:file, :no_trainees)
      end

      def not_a_trainee_row?
        rows[0].any? do |cell|
          # Either they've deleted all their trainees
          cell.include?(Reports::BulkRecommendReport::DO_NOT_EDIT) ||
            # Or they managed to export an empty CSV
            cell.include?("No trainee data to export")
        end
      end

      def all_headers
        Reports::BulkRecommendReport::DEFAULT_HEADERS.map(&:downcase)
      end

      def headers
        @headers ||= csv.headers
      end

      def rows
        @rows ||= csv.entries
      end
    end
  end
end
