# frozen_string_literal: true

module PageObjects
  module RecommendationsChecks
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/check-who-youll-recommend"

      element :upload_button, ".govuk-button", text: "Upload file and check who you’ll recommend"
      element :change_link, ".govuk-link", text: "Change who you’ll recommend"
    end
  end
end
