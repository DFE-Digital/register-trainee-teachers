# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Edit < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/change-who-youll-recommend"

      element :upload_button, ".govuk-button", text: "Upload file and check whose status has changed"
    end
  end
end
