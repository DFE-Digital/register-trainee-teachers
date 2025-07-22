# frozen_string_literal: true

require "net/http"

module SchoolData
  class SchoolDataDownloader
    include ServicePattern

    ESTABLISHMENT_TYPES = [1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 14, 15, 18, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 49, 56, 57].freeze

    def call
      download_and_filter_csv
    end

  private

    def download_and_filter_csv
      filtered_file = Tempfile.new(["school_data_filtered_", ".csv"])
      total_rows = 0
      filtered_rows = 0
      establishment_type_index = nil

      begin
        uri = URI(csv_url)
        response_body = Net::HTTP.get_response(uri)
        response_body.value # Raises an exception for HTTP error responses

        csv_content = response_body.body.dup
        csv_content.force_encoding("windows-1251").encode("utf-8")

        csv_content.each_line.with_index do |line, line_index|
          line = line.strip
          next if line.empty?

          if line_index.zero?
            headers = CSV.parse_line(line)
            establishment_type_index = headers.index("TypeOfEstablishment (code)")

            if establishment_type_index.nil?
              raise("Could not find 'TypeOfEstablishment (code)' column in CSV headers")
            end

            filtered_file.puts(line)
            next
          end

          total_rows += 1

          begin
            fields = CSV.parse_line(line)
            establishment_type = fields[establishment_type_index].to_i

            if ESTABLISHMENT_TYPES.include?(establishment_type)
              filtered_file.puts(line)
              filtered_rows += 1
            end
          rescue CSV::MalformedCSVError
            next
          end
        end

        filtered_file.flush
        filtered_file.close

        Rails.logger.info("Filtered #{filtered_rows} schools from #{total_rows} rows")
        filtered_file.path
      rescue StandardError => e
        filtered_file&.close
        filtered_file&.unlink
        raise(e)
      end
    end

    def csv_url
      format(Settings.school_data.downloader.base_url, Date.current.strftime("%Y%m%d"))
    end
  end
end
