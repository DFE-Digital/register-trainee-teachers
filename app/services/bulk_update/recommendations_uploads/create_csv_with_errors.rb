# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class CreateCsvWithErrors
      include ServicePattern

      def initialize(recommendations_upload:)
        @recommendations_upload = recommendations_upload
      end

      def call
        table = download_csv

        table.each.with_index do |row, index|
          # The first row in the table is the "Do not edit" row
          if index.zero?
            row["Errors"] = "Do not edit"
          else
            # We add 2 here because the first data row is actually the third
            # csv row (after headers and "Do not edit" row)
            row["Errors"] = errors_for_row(index + 2)
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
