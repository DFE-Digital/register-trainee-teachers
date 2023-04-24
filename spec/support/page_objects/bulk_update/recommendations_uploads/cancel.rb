# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Cancel < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/cancel-bulk-updates"

      element :confirm_button, ".govuk-button", text: "Cancel bulk recommending trainees"
    end
  end
end
