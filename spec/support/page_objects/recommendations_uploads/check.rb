# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Check < PageObjects::Base
      set_url "/bulk-update/recommend/{recommendations_upload_id}/check-pending-updates"

      element :change_link, ".govuk-link", text: "Change who you’ll recommend"
    end
  end
end
