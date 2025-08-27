# frozen_string_literal: true

require "net/http"

module SchoolData
  class SchoolDataDownloader
    include ServicePattern

    def call
      download_csv
    end

  private

    def download_csv
      uri = URI(csv_url)
      response_body = Net::HTTP.get_response(uri)
      response_body.value # Raises an exception for HTTP error responses

      csv_content = response_body.body.dup
      csv_content.force_encoding("windows-1251").encode("utf-8")
    end

    def csv_url
      format(Settings.school_data.downloader.base_url, 1.day.ago.strftime("%Y%m%d"))
    end
  end
end
