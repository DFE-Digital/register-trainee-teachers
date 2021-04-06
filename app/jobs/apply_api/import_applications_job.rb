# frozen_string_literal: true

module ApplyApi
  class ImportApplicationsJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_applications_from_apply")

      new_applications.each do |application|
        ImportApplication.call(application: application)
      end
    end

  private

    def new_applications
      RetrieveApplications.call(changed_since: last_successful_sync)
    end

    def last_successful_sync
      ApplyApplicationSyncRequest.successful.pluck(:created_at).max
    end
  end
end
