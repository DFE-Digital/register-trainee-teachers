# frozen_string_literal: true

require "zip"
require "tmpdir"

module SchoolData
  class CsvScraper
    include ServicePattern

    # Form field IDs from the GIAS website
    STATE_FUNDED_CHECKBOX_ID = "state-funded-school--elds-csv-checkbox"
    ACADEMIES_CHECKBOX_ID = "academies-and-free-school--elds-csv-checkbox"
    DOWNLOAD_BUTTON_ID = "download-selected-files-button"
    RESULTS_DOWNLOAD_BUTTON_ID = "download-button"

    class FormStructureChangedError < StandardError; end
    class DownloadError < StandardError; end
    class ExtractionError < StandardError; end
    class AccessDeniedError < StandardError; end

    attr_reader :extracted_files, :extract_path, :download_record, :error_message

    def initialize(extract_path: Dir.mktmpdir("school_data_"))
      @extract_path = extract_path
      @extracted_files = []
      @download_record = SchoolDataDownload.create!(started_at: Time.current, status: :pending)
      @error_message = nil
    end

    def call
      @download_record.update!(status: :downloading)
      download_and_extract_zip
      @download_record.update!(status: :extracting)
      validate_extraction
      self
    rescue StandardError => e
      @error_message = e.message
      @download_record.update!(
        status: :failed,
        completed_at: Time.current,
        error_message: e.message,
      )
      Rails.logger.error("CSV scraping failed: #{e.message}")
      self
    end

    def success?
      error_message.nil?
    end

    def cleanup!
      return unless Dir.exist?(extract_path)

      FileUtils.rm_rf(extract_path)
      @extracted_files = []
    end

  private

    def download_and_extract_zip
      # Step 1: Submit form with school data checkboxes
      page = agent.get(gias_downloads_url)
      form = find_and_validate_form(page)
      select_school_data_checkboxes(form)

      # Submit the form
      sleep(2) # Small delay to be respectful to the server
      results_page = agent.submit(form, form.button_with(id: DOWNLOAD_BUTTON_ID))

      # Step 2: Download ZIP from results page
      sleep(1) # Small delay before downloading
      zip_data = download_zip_file(agent, results_page)

      # Step 3: Extract CSV files
      extract_csv_files(zip_data)
    rescue Mechanize::ResponseCodeError => e
      handle_http_error(e)
    rescue Mechanize::Error => e
      raise(DownloadError, "Mechanize error: #{e.message}")
    end

    def find_and_validate_form(page)
      form = page.forms.find { |f| f.action&.include?("Downloads/Collate") } ||
             page.forms.find { |f| f.method&.downcase == "post" } ||
             page.forms.first

      raise(FormStructureChangedError, "No form found on GIAS downloads page") unless form

      # Validate that the expected checkboxes exist
      state_funded_checkbox = form.checkbox_with(id: STATE_FUNDED_CHECKBOX_ID)
      academies_checkbox = form.checkbox_with(id: ACADEMIES_CHECKBOX_ID)

      notify_form_structure_changed(form) unless state_funded_checkbox && academies_checkbox

      form
    end

    def select_school_data_checkboxes(form)
      form.checkbox_with(id: STATE_FUNDED_CHECKBOX_ID).check
      form.checkbox_with(id: ACADEMIES_CHECKBOX_ID).check
    end

    def download_zip_file(agent, results_page)
      # Wait for the Results.zip download button to appear (it's loaded via JS)
      download_form = wait_for_download_button(agent, results_page)

      unless download_form
        raise(DownloadError, "Results.zip download button did not appear within timeout period")
      end

      zip_response = agent.submit(download_form, download_form.button_with(id: RESULTS_DOWNLOAD_BUTTON_ID))
      zip_response.body
    end

    def extract_csv_files(zip_data)
      FileUtils.mkdir_p(extract_path)

      Zip::File.open_buffer(zip_data) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name.end_with?(".csv")

          output_path = File.join(extract_path, File.basename(entry.name))

          entry.extract(output_path) { true } # Overwrite if exists

          @extracted_files << output_path
        end
      end

      if extracted_files.empty?
        raise(ExtractionError, "No CSV files found in downloaded ZIP")
      end
    rescue Zip::Error => e
      raise(ExtractionError, "Failed to extract ZIP file: #{e.message}")
    end

    def validate_extraction
      unless extracted_files.size == 2
        Rails.logger.warn("Expected 2 CSV files but extracted #{extracted_files.size}: #{extracted_files}")
      end

      extracted_files.each do |file_path|
        unless File.exist?(file_path) && File.size(file_path).positive?
          raise(ExtractionError, "Extracted file is missing or empty: #{file_path}")
        end
      end
    end

    def agent
      @agent ||= begin
        agent = Mechanize.new

        agent.user_agent = Settings.school_data.scraper.user_agent

        # Set headers that match a real browser
        agent.request_headers = {
          "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
          "Accept-Language" => "en-GB,en;q=0.9,en-US;q=0.8",
          "Accept-Encoding" => "gzip, deflate, br",
          "DNT" => "1",
          "Connection" => "keep-alive",
          "Upgrade-Insecure-Requests" => "1",
          "Sec-Fetch-Dest" => "document",
          "Sec-Fetch-Mode" => "navigate",
          "Sec-Fetch-Site" => "none",
          "Sec-Fetch-User" => "?1",
        }

        agent.read_timeout = Settings.school_data.scraper.request_timeout
        agent.follow_meta_refresh = true
        agent.redirect_ok = true

        agent
      end
    end

    def notify_form_structure_changed(form)
      available_checkboxes = form.checkboxes.map { |cb| cb["id"] || cb.name }.compact
      Rails.logger.error("GIAS form structure changed! Expected checkboxes not found. Available: #{available_checkboxes.join(', ')}")
      raise(FormStructureChangedError, "Required form checkboxes not found - GIAS site structure changed")
    end

    def wait_for_download_button(agent, results_page)
      max_wait_time = Settings.school_data.scraper.download_timeout
      check_interval = Settings.school_data.scraper.check_interval
      elapsed_time = 0

      while elapsed_time < max_wait_time
        # Get fresh page content to check if download button is ready
        current_page = agent.get(results_page.uri.to_s)

        # Look for the download form with our button
        download_form = current_page.forms.find { |f| f.button_with(id: RESULTS_DOWNLOAD_BUTTON_ID) }

        if download_form
          return download_form
        end

        sleep(check_interval)
        elapsed_time += check_interval
      end

      Rails.logger.error("Download button did not appear within #{max_wait_time} seconds")
      nil
    end

    def handle_http_error(error)
      case error.response_code
      when "403"
        message = "Access denied (403) - GIAS website may have anti-bot protection. This could be due to:\n" \
                  "- Rate limiting or IP blocking\n" \
                  "- Bot detection (despite browser-like headers)\n" \
                  "- Temporary server restrictions\n" \
                  "Try again later or contact the GIAS team if the issue persists."
        raise(AccessDeniedError, message)
      when "404"
        raise(DownloadError, "GIAS downloads page not found (404) - URL may have changed: #{gias_downloads_url}")
      when "500", "502", "503", "504"
        raise(DownloadError, "GIAS server error (#{error.response_code}) - their service may be temporarily unavailable")
      else
        raise(DownloadError, "HTTP error #{error.response_code}: #{error.message}")
      end
    end

    def gias_downloads_url
      Settings.school_data.scraper.url
    end
  end
end
