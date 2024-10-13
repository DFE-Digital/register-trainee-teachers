# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRowsJob < ApplicationJob
      queue_as :bulk_update

      def perform(id:)
        return unless FeatureService.enabled?(:bulk_add_trainees)

        ImportRows.call(id:)
      end
    end
  end
end
