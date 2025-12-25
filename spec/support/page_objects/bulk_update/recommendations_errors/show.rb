# frozen_string_literal: true

module PageObjects
  module RecommendationsErrors
    class Show < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/review-errors"

      element :upload_button, ".govuk-button", text: "Upload file and check whose status will change"
    end
  end
end
