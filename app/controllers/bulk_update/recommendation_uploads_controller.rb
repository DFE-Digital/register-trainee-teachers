# frozen_string_literal: true

module BulkUpdate
  class RecommendationUploadsController < ApplicationController
    def show; end

    def new; end

    def create
      redirect_to(bulk_update_recommendation_upload_summary_path(1))
    end

    def check; end
  end
end
