# frozen_string_literal: true

module BulkUpdate
  class RecommendationUploadsController < ApplicationController
    # TODO: Find the user's upload and pick out counts
    def show; end

    def new
      @bulk_recommend_count = policy_scope(FindBulkRecommendTrainees.call).count
    end

    def create
      # TODO: Actually save a recommendation_upload here
      redirect_to(bulk_update_recommendation_upload_summary_path(1))
    end

    # TODO: Find the user's upload trainees
    def check; end
  end
end
