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

        record.errors.add(:file, :invalid_headers, explanations: error_explanations)
      end

      def error_explanations
        missing_columns = BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys - headers
        extra_columns = headers - BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys

        explanations = []
        if missing_columns.any?
          explanations << "Your file is missing the following columns: #{missing_columns.map { |col| "'#{col}'" }.to_sentence}"
        elsif extra_columns.any?
          explanations << "Your file has the following extra columns: #{extra_columns.map { |col| "'#{col}'" }.to_sentence}"
        end

        explanations.join(". ")
      end

      def trainees!
        return unless rows.empty?

        record.errors.add(:file, :no_trainees)
      end

      def headers
        @headers ||= csv.headers - ["Validation results", "Errors"]
      end

      def rows
        @rows ||= csv.entries.reject { |entry| entry.to_h.values.all?(&:blank?) }
      end
    end
  end
end
