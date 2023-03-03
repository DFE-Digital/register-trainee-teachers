# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class New < PageObjects::Base
      set_url "/bulk-update/recommend/upload"

      element :upload_button, ".govuk-button", text: "Upload file and check who you’ll recommend"
      element :export_link, ".govuk-link", class: "bulk-recommend"
    end
  end
end
