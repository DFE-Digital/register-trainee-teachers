# frozen_string_literal: true

module PageObjects
  module RecommendationsChecks
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/check-who-youll-recommend"

      element :upload_button, ".govuk-button", text: "Upload file and check whose status will change"
      element :change_link, ".govuk-link", text: "Change whose status is changing"
    end
  end
end
