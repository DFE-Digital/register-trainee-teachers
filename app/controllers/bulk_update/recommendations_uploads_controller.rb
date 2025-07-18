# frozen_string_literal: true

module BulkUpdate
  class RecommendationsUploadsController < RecommendationsBaseController
    helper_method :organisation_filename_prepopulated, :organisation_filename_empty

    def new
      @recommendations_upload_form = RecommendationsUploadForm.new
    end

    def edit
      @recommendations_upload_form = RecommendationsUploadForm.new
    end

    def create
      @recommendations_upload_form = RecommendationsUploadForm.new(provider:, file:)

      if @recommendations_upload_form.save
        create_rows!
        redirect_to(bulk_update_recommendations_upload_summary_path(@recommendations_upload_form.recommendations_upload))
      else
        render(:new)
      end
    end

    def update
      @recommendations_upload_form = RecommendationsUploadForm.new(provider:, file:)

      if @recommendations_upload_form.save
        create_rows!
        redirect_to(bulk_update_recommendations_upload_summary_path(@recommendations_upload_form.recommendations_upload))
      else
        render(:edit)
      end
    end

  private

    attr_reader :recommendations_upload_form

    def file
      @file ||= params.dig(:bulk_update_recommendations_upload_form, :file)
    end

    def organisation_filename_prepopulated
      "#{provider.name.parameterize}-trainees-to-select-prepopulated.csv"
    end

    def organisation_filename_empty
      "#{provider.name.parameterize}-trainees-to-select-empty.csv"
    end

    # for now, if anything goes wrong during creation of trainees
    # delete the recommend_upload record (and uploaded file)
    def create_rows!
      recommendations_upload = @recommendations_upload_form.recommendations_upload

      RecommendationsUploads::CreateRecommendationsUploadRows.call(
        recommendations_upload: recommendations_upload,
        csv: @recommendations_upload_form.csv,
      )
    rescue StandardError => e
      recommendations_upload.destroy
      raise(e)
    end
  end
end
