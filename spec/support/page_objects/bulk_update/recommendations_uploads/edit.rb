# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Edit < PageObjects::Base
      set_url "/bulk-update/recommend/{id}/change-who-youll-recommend"
    end
  end
end
