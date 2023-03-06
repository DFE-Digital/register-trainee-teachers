# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class CreateRecommendationsUploadRows
      include ServicePattern

      def initialize(recommendations_upload:, csv:)
        @recommendations_upload = recommendations_upload
        @csv = csv
      end

      # we skip the first non-header row as this will just contain "do not edit" warning.
      def call
        csv[1..].map.with_index(3) do |row, row_number|
          validation = ValidateCsvRow.new(row)

          upload_row = recommendations_upload.rows.create(
            csv_row_number: row_number,
            standards_met_at: row["date qts or eyts standards met"].to_date,
            trn: row["trn"],
            hesa_id: row["heas id"],
          )

          validation.messages.each do |message|
            upload_row.row_errors.create(message:)
          end
        end
      end

    private

      attr_reader :recommendations_upload, :csv
    end
  end
end
