# frozen_string_literal: true

# takes the headers defined in our BulkRecommend export and returns us a cleaner way
# to access the CSV row attributes e.g.:
#
# row = Row.new({ "Provider trainee ID" => "1234" })
# #<Row:0x007fb3a1755178 @provider_trainee_id="1234">
# row.provider_trainee_id
# #=> "1234"
#
module BulkUpdate
  module RecommendationsUploads
    class Row < RowBase
      def standards_met_at
        send("date_qts_or_eyts_requirement_met")
      end

      def sanitised_hesa_id
        send("hesa_id")&.gsub(/[^\d]/, "")
      end

    private

      def headers
        @headers ||= ::Reports::BulkRecommendReport::DEFAULT_HEADERS
      end
    end
  end
end
