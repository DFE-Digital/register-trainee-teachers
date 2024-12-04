# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class RemoveCancelledAndFailedJob < ApplicationJob
      queue_as :default

      def perform
        return unless FeatureService.enabled?(:bulk_add_trainees)

        RemoveUploads.call
      end
    end
  end
end
