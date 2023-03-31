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
        identifier_header!
        date_header!
        dates!
      end

    private

      attr_reader :csv, :record

      def identifier_header!
        return if headers & identifying_headers != []

        record.errors.add(:file, :no_id_header)
      end

      def identifying_headers
        Reports::BulkRecommendReport::IDENTIFIERS.map(&:downcase)
      end

      def date_header!
        return if headers.include?(date_header)

        record.errors.add(:file, :no_date_header)
      end

      def date_header
        Reports::BulkRecommendReport::DATE.downcase
      end

      def dates!
        return unless headers.include?(date_header)
        return if csv[date_header].to_a.map(&:presence).any?

        record.errors.add(:file, :no_dates_given)
      end

      def headers
        @headers ||= csv.headers
      end
    end
  end
end
