# frozen_string_literal: true

module SystemAdmin
  class UploadView
    def initialize(upload)
      @upload = upload
    end

    def name
      return "File pending approval" unless upload.scan_result_clean?

      upload.name
    end

    attr_reader :upload

    delegate :id, :user, :malware_scan_result, :file, to: :upload
  end
end
