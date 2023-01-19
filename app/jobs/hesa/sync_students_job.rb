# frozen_string_literal: true

module Hesa
  class SyncStudentsJob < ApplicationJob
    queue_as :hesa

    def perform
      return unless FeatureService.enabled?("hesa_import.sync_collection")

      SyncStudents.call
    end
  end
end
