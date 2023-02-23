# frozen_string_literal: true

module BulkUpdate
  class AwardRecommendationsController < ApplicationController
    def create
      redirect_to(bulk_update_recommendation_upload_confirmation_path(1))
    end
  end
end
