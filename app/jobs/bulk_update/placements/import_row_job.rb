# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportRowJob < ApplicationJob
      queue_as :bulk_update

      def perform(placement_row)
        ImportRow.call(placement_row)
      rescue StandardError => e
        placement_row.failed!
        placement_row.row_errors.create(message: "runtime failure: #{e.message}")
      end
    end
  end
end
