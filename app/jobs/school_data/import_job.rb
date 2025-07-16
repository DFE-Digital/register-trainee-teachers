# frozen_string_literal: true

module SchoolData
  class ImportJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("school_data_auto_import")

      Rails.logger.info("Starting school data import job")

      scraper_result = SchoolData::CsvScraper.call

      if scraper_result.success? && scraper_result.extracted_files.size == 2
        SchoolData::ImportService.call(
          csv_files: scraper_result.extracted_files,
          download_record: scraper_result.download_record,
        )

        Rails.logger.info("School data import job completed successfully")
      else
        handle_scraper_failure(scraper_result)
      end
    rescue StandardError => e
      handle_import_failure(e)
      raise
    end

  private

    def handle_scraper_failure(scraper_result)
      error_message = scraper_result.error_message || "Unknown scraper error"
      Rails.logger.error("School data scraper failed: #{error_message}")
    end

    def handle_import_failure(error)
      Rails.logger.error("School data import job failed: #{error.message}")
    end
  end
end
