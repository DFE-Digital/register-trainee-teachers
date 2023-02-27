# frozen_string_literal: true

module BulkUpdate
  class RecommendationUploadsController < ApplicationController
    helper_method :bulk_recommend_count, :recommendations_upload_form

    # TODO: Find the user's upload and pick out counts
    def show; end

    def new
      @recommendations_upload_form = RecommendationsUploadForm.new
    end

    def create
      @recommendations_upload_form = RecommendationsUploadForm.new(current_user:, file:)

      if recommendations_upload_form.save
        create_recommended_trainees!
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

    def bulk_recommend_count
      @bulk_recommend_count ||= policy_scope(FindBulkRecommendTrainees.call).count
    end

    # for now, if anything goes wrong during creation of trainees
    # delete the recommend_upload record (and uploaded file)
    #
    # the local tempfile is re-used here to save time (i.e. avoids downloading it from Azure)
    def create_recommended_trainees!
      file.tempfile.rewind

      Recommend::CreateTrainees.call(
        recommendations_upload_id: recommendations_upload.id,
        # csv: CSV.new(file.tempfile, headers: true).read,
        csv: recommendations_upload_form.csv,
      )
    rescue StandardError
      recommendations_upload.destroy
    end
  end
end
