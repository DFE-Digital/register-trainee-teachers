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
    class Row
      def initialize(csv_row)
        ::Reports::BulkRecommendReport::DEFAULT_HEADERS.each do |header|
          method_name = header.downcase.gsub(" ", "_")
          method_value = csv_row[header.downcase]

          instance_variable_set("@#{method_name}", method_value)
          self.class.send(:attr_reader, method_name)
        end
      end

      def standards_met_at
        send("date_qts_or_eyts_standards_met")
      end

      def sanitised_hesa_id
        send("hesa_id")&.gsub(/[^\d]/, "")
      end
    end
  end
end
