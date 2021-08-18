# frozen_string_literal: true

module ApplyApi
  class ImportApplicationsJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("import_applications_from_apply")

      new_applications.each do |application_data|
        application_record = ImportApplication.call(application_data: application_data)
        Trainees::CreateFromApply.call(application: application_record) if application_record.present?
      rescue ApplyApi::ImportApplication::ApplyApiMissingDataError
        Sentry.capture_message "The data from Apply has missing attributes, Application ID: #{application_data['id']}"
      end
    end

  private

    def new_applications
      RetrieveApplications.call(changed_since: last_successful_sync)
    end

    def last_successful_sync
      ApplyApplicationSyncRequest.successful.maximum(:created_at)
    end
  end
end
