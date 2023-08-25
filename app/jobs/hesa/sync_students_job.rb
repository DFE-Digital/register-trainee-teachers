# frozen_string_literal: true

module Hesa
  class SyncStudentsJob < ApplicationJob
    queue_as :hesa

    def perform(upload_id: nil)
      return unless FeatureService.enabled?("hesa_import.sync_collection")

      SyncStudents.call(upload_id:)
    end
  end
end
