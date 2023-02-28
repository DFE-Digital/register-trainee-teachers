# frozen_string_literal: true

module BulkUpdate
  module RecommendationsUploads
    class CreateTrainees
      include ServicePattern

      def initialize(recommendations_upload_id:, csv:)
        @recommendations_upload_id = recommendations_upload_id
        @csv = csv
      end

      # we skip the first non-header row as this will just contain "do not edit" warning.
      def call
        csv[1..].map.with_index(3) do |row, row_number|
          ::BulkUpdate::RecommendedTrainee.create(
            bulk_update_recommendations_upload_id: recommendations_upload_id,
            csv_row_number: row_number,
            standards_met_at: row["Date QTS or EYTS standards met"].to_date,
            trn: row["TRN"],
            hesa_id: row["HESA ID"],
          )
        end
      end

    private

      attr_reader :recommendations_upload_id, :csv
    end
  end
end
