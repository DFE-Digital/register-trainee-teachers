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
    end

  private

    def download_and_filter_csv
      url = csv_url
      Rails.logger.info("Downloading school data from: #{url}")

      # Create temporary file for filtered results
      filtered_file = Tempfile.new(["school_data_filtered_", ".csv"])
      total_rows = 0
      filtered_rows = 0
      establishment_type_index = nil

      begin
        # Stream download and process line by line to avoid loading 60MB into memory
        URI.open(url, read_timeout: Settings.school_data&.downloader&.timeout || 300) do |csv_stream|
          csv_stream.set_encoding("windows-1251:utf-8")

          csv_stream.each_line.with_index do |line, line_index|
            line = line.strip
            next if line.empty?

            if line_index == 0
              # Header row - find the establishment type column and write headers
              headers = CSV.parse_line(line)
              establishment_type_index = headers.index("TypeOfEstablishment (code)")

              if establishment_type_index.nil?
                raise("Could not find 'TypeOfEstablishment (code)' column in CSV headers")
              end

              filtered_file.puts(line)
              Rails.logger.info("Found establishment type column at index #{establishment_type_index}")
              next
            end

            total_rows += 1

            # Parse just the establishment type column to check filter
            begin
              fields = CSV.parse_line(line)
              establishment_type = fields[establishment_type_index].to_i

              if ESTABLISHMENT_TYPES.include?(establishment_type)
                filtered_file.puts(line)
                filtered_rows += 1

                # Debug first few rows
                log_debug_info(establishment_type, fields, filtered_rows) if filtered_rows <= 10
              end
            rescue CSV::MalformedCSVError
              # Skip malformed lines
              Rails.logger.warn("Skipping malformed CSV line #{line_index + 1}")
            end

            # Log progress every 10,000 rows
            if (total_rows % 10_000).zero?
              Rails.logger.info("Processed #{total_rows} rows, filtered #{filtered_rows} rows")
            end
          end
        end

        Rails.logger.info("Processed #{total_rows} rows, filtered #{filtered_rows} rows")

        filtered_file.flush # Ensure all data is written
        filtered_file.close

        # Verify the filtered file was created properly
        if File.size(filtered_file.path) == 0
          raise("Filtered CSV file is empty - no schools matched filter criteria")
        end

        Rails.logger.info("Created filtered CSV: #{filtered_file.path} (#{File.size(filtered_file.path)} bytes)")
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

    def log_debug_info(establishment_type, fields, filtered_rows)
      school_name = fields[4] # EstablishmentName is typically the 5th column (index 4)
      Rails.logger.info("Row #{filtered_rows}: Type=#{establishment_type}, School='#{school_name}'")
    end
  end
end
