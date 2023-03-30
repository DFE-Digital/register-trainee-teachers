# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class CreateCsvWithErrors
      include ServicePattern

      FIRST_CSV_ROW_NUMBER = 2

      def initialize(recommendations_upload:)
        @recommendations_upload = recommendations_upload
      end

      def call
        table = download_csv

        table.each.with_index do |row, index|
          # If we're dealing with a "Do not edit" row, add another "Do not edit"
          if row.any? { |cell| cell.include?(Reports::BulkRecommendReport::DO_NOT_EDIT) }
            row["Errors"] = Reports::BulkRecommendReport::DO_NOT_EDIT
          else
            row["Errors"] = errors_for_row(index + FIRST_CSV_ROW_NUMBER)
          end
        end

        recommendations_upload.file.open do |file|
          file << table.headers
          table.each { |row| file << row }
        end
      end

    private

      attr_reader :recommendations_upload

      def download_csv
        @download_csv ||= CSV.new(
          recommendations_upload.file.download,
          headers: true,
        ).read
      end

      def errors_for_row(row_number)
        upload_row = recommendations_upload.rows.find_by(csv_row_number: row_number)
        return nil if upload_row.nil?

        upload_row.row_error_messages
      end
    end
  end
end
