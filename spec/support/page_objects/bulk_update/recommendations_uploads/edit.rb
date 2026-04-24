# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Edit < PageObjects::Base
      set_url "/bulk-update/change-status/{id}/change-whose-status-will-change"

      element :upload_button, ".govuk-button", text: "Upload file and check whose status has changed"
    end
  end
end
