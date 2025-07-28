# frozen_string_literal: true

module SchoolData
  class ImportJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?(:school_data_auto_import)

      download_record = SchoolDataDownload.create!(
        status: :running,
        started_at: Time.current,
      )

      csv_content = SchoolData::SchoolDataDownloader.call

      SchoolData::ImportService.call(
        csv_content:,
        download_record:,
      )

      download_record
    rescue StandardError
      download_record&.update(status: :failed, completed_at: Time.current)
      raise
    end
  end
end
