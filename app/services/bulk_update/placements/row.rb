# frozen_string_literal: true

module BulkUpdate
  module Placements
    class Row < RowBase
      def urns
        Config::MAX_PLACEMENTS.times.map do |index|
          number = index + 1
          csv_row["placement #{number} urn"].presence
        end.compact
      end

    private

      def headers
        @headers ||= ::Reports::BulkPlacementReport::HEADERS
      end
    end
  end
end
