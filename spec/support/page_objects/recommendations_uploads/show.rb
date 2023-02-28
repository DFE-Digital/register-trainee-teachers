# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/upload-summary"

      element :check_button, ".govuk-button", text: "Check who you’ll recommend"
    end
  end
end
