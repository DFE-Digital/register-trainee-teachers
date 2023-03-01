# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadsController < ApplicationController
    helper_method :bulk_recommend_count, :recommendations_upload_form
    before_action :redirect

    # TODO: Find the user's upload and pick out counts
    def show; end

    def new
      @recommendations_upload_form = RecommendationsUploadForm.new
    end

    def create
      @recommendations_upload_form = RecommendationsUploadForm.new(provider:, file:)

      if recommendations_upload_form.save
        create_rows!
        redirect_to(root_path)
      else
        render(:new)
      end
    end

    # TODO: Find the user's upload trainees
    def check; end

  private

    attr_reader :recommendations_upload_form

    delegate :recommendations_upload, to: :recommendations_upload_form

    def file
      @file ||= params[:bulk_update_recommendations_upload_form][:file]
    end

    def provider
      @provider ||= current_user.organisation
    end

    def bulk_recommend_count
      @bulk_recommend_count ||= policy_scope(FindBulkRecommendTrainees.call).count
    end

    # for now, if anything goes wrong during creation of trainees
    # delete the recommend_upload record (and uploaded file)
    def create_rows!
      RecommendationsUploads::CreateRecommendationsUploadRows.call(
        recommendations_upload_id: recommendations_upload.id,
        csv: recommendations_upload_form.csv,
      )
    rescue StandardError
      recommendations_upload.destroy
    end

    def redirect
      redirect_to(root_path) unless provider.is_a?(Provider)
    end
  end
end
