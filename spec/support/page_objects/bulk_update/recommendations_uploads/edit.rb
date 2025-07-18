# frozen_string_literal: true

module PageObjects
  module RecommendationsUploads
    class Edit < PageObjects::Base
      set_url "/bulk-update/select/{id}/change-who-youll-select"
    end
  end
end
