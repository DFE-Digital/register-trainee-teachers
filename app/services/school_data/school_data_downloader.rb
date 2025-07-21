# frozen_string_literal: true

module SchoolData
  class SchoolDataDownloader
    include ServicePattern

    ESTABLISHMENT_TYPES = [1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 14, 15, 18, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 49, 56, 57].freeze

    attr_reader :filtered_csv_path, :download_record

    def initialize(download_record:)
      @download_record = download_record
    end

    def call
      Rails.logger.info("Starting school data download and filtering")

      @filtered_csv_path = download_and_filter_csv
      self
    rescue StandardError => e
      handle_error(e)
      raise
    end

  private

    def download_and_filter_csv
      # Create temporary file for filtered results
      filtered_file = Tempfile.new(["school_data_filtered_", ".csv"])
      headers_written = false
      total_rows = 0
      filtered_rows = 0

      begin
        # Stream download and process line by line to avoid loading 60MB into memory
        URI.open(csv_url, read_timeout: Settings.school_data&.downloader&.timeout || 300) do |csv_stream|
          CSV.new(csv_stream, headers: true, encoding: "utf-8").each do |row|
            total_rows += 1

            # Write headers on first row
            unless headers_written
              filtered_file.puts(row.headers.to_csv)
              headers_written = true
            end

            # Filter based on establishment type
            if should_include_row?(row)
              filtered_file.puts(row.to_csv)
              filtered_rows += 1
            end

            # Log progress every 10,000 rows
            if (total_rows % 10_000).zero?
              Rails.logger.info("Processed #{total_rows} rows, filtered #{filtered_rows} rows")
            end
          end
        end

        Rails.logger.info("Processed #{total_rows} rows, filtered #{filtered_rows} rows")

        filtered_file.close
        filtered_file.path
      rescue StandardError => e
        filtered_file&.close
        filtered_file&.unlink
        raise(e)
      end
    end

    def csv_url
      base_url = Settings.school_data&.downloader&.base_url || "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata%s.csv"
      format(base_url, Date.current.strftime("%Y%m%d"))
    end

    def should_include_row?(row)
      establishment_type = row["TypeOfEstablishment (code)"].to_i
      ESTABLISHMENT_TYPES.include?(establishment_type)
    end

    def handle_error(error)
      Rails.logger.error("School data download failed: #{error.message}")
      Rails.logger.error(error.backtrace.join("\n"))

      @download_record.update!(
        status: :failed,
        completed_at: Time.current,
        error_message: error.message,
      )

      # Clean up any temporary files
      cleanup_files
    end

    def cleanup_files
      if @filtered_csv_path && File.exist?(@filtered_csv_path)
        File.unlink(@filtered_csv_path)
      end
    rescue StandardError => e
      Rails.logger.warn("Failed to cleanup temporary file: #{e.message}")
    end
  end
end
