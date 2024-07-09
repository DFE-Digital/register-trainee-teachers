# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Confirmation < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/confirmation"

      element :page_title, ".govuk-panel__title"
    end
  end
end
