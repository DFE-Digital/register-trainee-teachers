# frozen_string_literal: true

module ApplyApi
  class ImportApplicationsJob < ApplicationJob
    queue_as :default

    def perform(from_date: nil)
      @from_date = from_date

      return unless FeatureService.enabled?("import_applications_from_apply")

      new_applications.each do |application_data|
        ImportApplication.call(application_data: application_data)
      rescue ApplyApi::ImportApplication::ApplyApiMissingDataError => e
        Sentry.capture_exception(e)
      end
    end

  private

    def new_applications
      RetrieveApplications.call(changed_since: @from_date || last_successful_sync)
    end

    def last_successful_sync
      ApplyApplicationSyncRequest.successful.maximum(:created_at)
    end
  end
end
