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
        true
      end

      def trainees!
        return unless csv.empty?

        record.errors.add(:file, :no_trainees)
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
