# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Check < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/check-pending-updates"

      element :recommend_button, "#recommend"
    end
  end
end
