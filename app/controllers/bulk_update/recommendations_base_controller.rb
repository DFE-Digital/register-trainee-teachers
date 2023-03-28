# frozen_string_literal: true

module BulkUpdate
  class RecommendationsBaseController < ApplicationController
    before_action :check_for_provider

    helper_method :recommendations_upload, :bulk_recommend_count,
                  :awardable_rows_count, :error_rows_count, :total_rows_count,
                  :missing_date_rows_count

  private

    def provider
      @provider ||= current_user.organisation
    end

    def check_for_provider
      redirect_to(root_path) unless provider.is_a?(Provider)
    end

    def bulk_recommend_count
      @bulk_recommend_count ||= policy_scope(FindBulkRecommendTrainees.call).count
    end

    def awardable_rows_count
      @awardable_rows_count ||= recommendations_upload.awardable_rows.size
    end

    def error_rows_count
      @error_rows_count ||= recommendations_upload.error_rows.size
    end

    def missing_date_rows_count
      @missing_date_rows_count ||= recommendations_upload.missing_date_rows.size
    end

    def total_rows_count
      @total_rows_count ||= recommendations_upload.rows.size
    end

    def recommendations_upload
      @recommendations_upload ||= provider.recommendations_uploads.find(params[:id] || params[:recommendations_upload_id])
    end
  end
end
