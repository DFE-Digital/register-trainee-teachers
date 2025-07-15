# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Cancel < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/cancel"

      element :confirm_button, ".govuk-button", text: "Cancel bulk selecting trainees"
    end
  end
end
