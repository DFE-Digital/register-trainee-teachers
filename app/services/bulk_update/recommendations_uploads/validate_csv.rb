# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsv
      def initialize(csv:, record:)
        @csv = csv
        @record = record
      end

      def validate!
        header_row!
        identifier_header!
        date_header!
        dates!
      end

    private

      attr_reader :csv, :record

      def header_row!
        return if headers.intersect?(all_headers)

        record.errors.add(:file, :no_header_detected)
      end

      def identifier_header!
        return if headers.intersect?(identifying_headers)

        record.errors.add(:file, :no_id_header)
      end

      def date_header!
        return if headers.include?(date_header)

        record.errors.add(:file, :no_date_header)
      end

      def dates!
        return unless headers.include?(date_header)
        return if date_cells_without_date_guidance.map(&:presence).any?

        record.errors.add(:file, :no_dates_given)
      end

      def date_cells_without_date_guidance
        csv[date_header].to_a.reject { |cell| cell&.downcase&.strip == Reports::BulkRecommendReport::DATE_GUIDANCE.downcase }
      end

      def all_headers
        Reports::BulkRecommendReport::DEFAULT_HEADERS.map(&:downcase)
      end

      def identifying_headers
        Reports::BulkRecommendReport::IDENTIFIERS.map(&:downcase)
      end

      def date_header
        Reports::BulkRecommendReport::DATE.downcase
      end

      def headers
        @headers ||= csv.headers
      end
    end
  end
end
