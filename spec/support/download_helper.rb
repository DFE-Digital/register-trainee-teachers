# frozen_string_literal: true

module DownloadHelper
  TIMEOUT = 10

  def downloads
    Dir[Capybara.save_path.join("*")]
  end

  def download
    downloads.first
  end

  def download_filename
    wait_for_download
    File.basename(download)
  end

  def download_content
    wait_for_download
    File.read(download)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end
