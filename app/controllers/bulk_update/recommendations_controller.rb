# frozen_string_literal: true

module BulkUpdate
  class RecommendationsController < RecommendationsBaseController
    def create
      Recommend.call(recommendations_upload:)

      redirect_to(bulk_update_recommendations_upload_confirmation_path(recommendations_upload))
    end
  end
end
