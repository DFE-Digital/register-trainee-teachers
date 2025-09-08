# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRowsJob < ApplicationJob
      queue_as :trainee_upload

      def perform(trainee_upload)
        return unless FeatureService.enabled?(:bulk_add_trainees)

        ImportRows.call(trainee_upload)
      end
    end
  end
end
