# frozen_string_literal: true

module BulkUpdate
  class RecommendationsChecksController < ApplicationController
    before_action :check_for_provider

    def show
      @table_row_limit = 50
      @recommendations_upload ||= provider.recommendations_uploads.find(params[:recommendations_upload_id])
      @awardable_rows_count = @recommendations_upload.awardable_rows.size
    end

  private

    def check_for_provider
      redirect_to(root_path) unless provider.is_a?(Provider)
    end

    def provider
      @provider ||= current_user.organisation
    end
  end
end
