# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/upload-summary"

      element :cancel_link, ".govuk-link", text: "Cancel bulk recommending trainees"
      element :check_button, ".govuk-button", text: "Check who you’ll recommend"
      element :review_errors_button, ".govuk-button", text: "Review errors"
    end
  end
end
