# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class ValidateCsv
      def initialize(csv:, record:)
        # Remove the non-data warning row
        csv.delete_if do |row|
          row.fields.any? { |cell| cell&.downcase&.include?(Reports::BulkRecommendReport::DO_NOT_EDIT.downcase) }
        end

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
        return if (headers & all_headers).any?

        record.errors.add(:file, :no_header_detected)
      end

      def identifier_header!
        return if (headers & identifying_headers).any?

        record.errors.add(:file, :no_id_header)
      end

      def date_header!
        return if headers.include?(date_header)

        record.errors.add(:file, :no_date_header)
      end

      def dates!
        return unless headers.include?(date_header)
        return if csv[date_header].to_a.map(&:presence).any?

        record.errors.add(:file, :no_dates_given)
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
