# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportRowsJob < ApplicationJob
      queue_as :bulk_update

      def perform(bulk_placement)
        ImportRows.call(bulk_placement)
      end
    end
  end
end
