# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Show < PageObjects::Base
      set_url "/bulk-update/select/{id}/review-errors"
    end
  end
end
