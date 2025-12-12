# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/upload-summary"

      element :cancel_link, ".govuk-link", text: "Cancel the bulk status change"
      element :check_button, ".govuk-button", text: "Check who"
      element :recommend_button, ".govuk-button", text: "Recommend"
      element :review_errors_button, ".govuk-button", text: "Review errors"
    end
  end
end
