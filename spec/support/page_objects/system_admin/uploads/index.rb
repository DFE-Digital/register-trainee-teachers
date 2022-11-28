# frozen_string_literal: true

module PageObjects
  module SystemAdmin
    module Uploads
      class Index < PageObjects::Base
        set_url "/system-admin/uploads"

        class UploadRow < SitePrism::Section
          element :link, ".upload-link"
        end

        element :upload_file, "a", text: "Upload File"
        element :search, 'input[name="search"]'
        element :submit_search, ".submit-search"
        sections :uploads, UploadRow, ".upload-row"
        element :flash_message, ".govuk-notification-banner__header"
        element :flash_message, ".govuk-notification-banner__header"
      end
    end
  end
end
