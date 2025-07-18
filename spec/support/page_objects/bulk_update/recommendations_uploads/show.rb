# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Show < PageObjects::Base
      set_url "/bulk-update/select/{id}/upload-summary"

      element :cancel_link, ".govuk-link", text: "Cancel bulk selecting trainees"
      element :check_button, ".govuk-button", text: "Check who you've selected"
      element :recommend_button, ".govuk-button", text: "Select"
      element :review_errors_button, ".govuk-button", text: "Review errors"
    end
  end
end
