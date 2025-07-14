# frozen_string_literal: true

module SchoolData
  class ImportJob < ApplicationJob
    queue_as :default

    def perform
      return unless FeatureService.enabled?("school_data_auto_import")

      Rails.logger.info("Starting school data import job")

      scraper_result = SchoolData::CsvScraper.call

      if scraper_result.success? && scraper_result.extracted_files.size == 2
        import_result = SchoolData::ImportService.call(
          csv_files: scraper_result.extracted_files,
          download_record: scraper_result.download_record,
        )

        notify_success(import_result, scraper_result.download_record)
        Rails.logger.info("School data import job completed successfully")
      else
        handle_scraper_failure(scraper_result)
      end
    rescue StandardError => e
      handle_import_failure(e)
      raise
    end

  private

    def notify_success(import_stats, download_record)
      message = build_success_message(import_stats, download_record)

      SlackNotifierService.call(
        message: message,
        username: "School Data Import Bot",
        icon_emoji: ":school:",
      )
    end

    def handle_scraper_failure(scraper_result)
      error_message = scraper_result.error_message || "Unknown scraper error"
      Rails.logger.error("School data scraper failed: #{error_message}")

      SlackNotifierService.call(
        message: ":warning: School data scraper failed!\n#{error_message}",
        username: "School Data Import Bot",
        icon_emoji: ":exclamation:",
      )
    end

    def handle_import_failure(error)
      Rails.logger.error("School data import job failed: #{error.message}")

      SlackNotifierService.call(
        message: ":rotating_light: School data import job failed!\nError: #{error.message}\nBacktrace: #{error.backtrace.first(3).join('\n')}",
        username: "School Data Import Bot",
        icon_emoji: ":fire:",
      )
    end

    def build_success_message(import_stats, download_record)
      duration = download_record.duration ? "#{(download_record.duration / 60).round(1)} minutes" : "unknown"

      <<~MESSAGE
        :white_check_mark: School data import completed successfully!

        **Summary:**
        • Schools created: #{import_stats[:created]}
        • Schools updated: #{import_stats[:updated]}
        • Errors: #{import_stats[:errors].size}
        • Files processed: #{download_record.file_count}
        • Duration: #{duration}

        #{import_stats[:errors].any? ? "**Errors:**\n#{format_errors(import_stats[:errors])}" : ''}
      MESSAGE
    end

    def format_errors(errors)
      errors.first(5).map { |err| "• URN #{err[:urn]}: #{err[:error]}" }.join("\n") +
        (errors.size > 5 ? "\n• ... and #{errors.size - 5} more errors" : "")
    end
  end
end
