# frozen_string_literal: true

module BulkUpdate
  class RecommendationsController < ApplicationController
    def create
      Recommend.call(recommendations_upload:)

      redirect_to(bulk_update_recommendations_upload_confirmation_path(recommendations_upload))
    end

  private

    def provider
      @provider ||= current_user.organisation
    end

    def recommendations_upload
      @recommendations_upload ||= provider.recommendations_uploads.find(params[:recommendations_upload_id])
    end
  end
end
