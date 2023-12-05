# frozen_string_literal: true

module BulkUpdate
  module Placements
    # creates placement_rows from a CSV
    class CreatePlacementRows
      include ServicePattern

      def initialize(bulk_placement:, csv:)
        @bulk_placement = bulk_placement
        @csv = csv
      end

      def call
        csv.each_with_index do |row, index|
          # skip the first guidance row
          next if guidance_row?(row)

          row = Row.new(row)
          csv_row_number = index + Config::FIRST_CSV_ROW_NUMBER

          create_bulk_placement_rows!(row, csv_row_number)
        end
      end

    private

      attr_reader :bulk_placement, :csv

      # a csv row will have multiple (up to MAX_PLACEMENTS) placement URNs
      # so we loop over these to create an individual row for each.
      def create_bulk_placement_rows!(row, csv_row_number)
        row.urns.each do |urn|
          bulk_placement.rows.create(
            trn: row.trn,
            urn: urn,
            csv_row_number: csv_row_number,
          )
        end
      end

      def guidance_row?(row)
        row.any? { |cell| cell.include?(Reports::BulkPlacementReport::GUIDANCE[0]) }
      end
    end
  end
end
