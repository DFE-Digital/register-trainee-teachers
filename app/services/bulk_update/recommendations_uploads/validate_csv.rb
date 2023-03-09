# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsv
      def initialize(csv:, record:)
        @csv = csv
        @record = record
      end

      # do all required headers exist in the CSV headers
      def validate!
        required_headers
      end

    private

      attr_reader :csv, :record

      VALID_HEADERS_SET = Set.new(Reports::BulkRecommendReport::DEFAULT_HEADERS.map(&:downcase))

      def required_headers
        unless csv_headers_set.superset?(VALID_HEADERS_SET)
          record.errors.add(:base, "CSV is missing the required headers")
        end
      end

      def csv_headers_set
        @csv_headers_set ||= Set.new(csv.headers)
      end
    end
  end
end
