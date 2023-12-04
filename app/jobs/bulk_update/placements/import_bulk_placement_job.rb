# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportBulkPlacementJob < ApplicationJob
      queue_as :bulk_update

      def perform(bulk_placement)
        ImportBulkPlacement.call(bulk_placement)
      end
    end
  end
end
