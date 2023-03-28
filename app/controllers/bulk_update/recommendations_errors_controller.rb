# frozen_string_literal: true

module BulkUpdate
  class RecommendationsErrorsController < RecommendationsBaseController
    def show
      respond_to do |format|
        format.html do
          @recommendations_upload_form = RecommendationsUploadForm.new
        end

        format.csv do
          send_data(csv_with_errors, filename: csv_with_errors_filename, disposition: :attachment)
        end
      end
    end

    def create
      @recommendations_upload_form = RecommendationsUploadForm.new(provider:, file:)

      if @recommendations_upload_form.save
        create_rows!
        @recommendations_upload.destroy # the new upload will replace the existing one
        redirect_to(bulk_update_recommendations_upload_summary_path(@recommendations_upload_form.recommendations_upload))
      else
        render(:show, format: :html)
      end
    end

  private

    attr_reader :recommendations_upload_form

    def csv_with_errors
      @csv_with_errors ||= RecommendationsUploads::CreateCsvWithErrors.call(recommendations_upload:)
    end

    def csv_with_errors_filename
      timestamp_regex = /\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_/

      # Remove any old timestamps or "errors_" that have been previously prepended
      base_filename = original_filename.gsub(Regexp.union(timestamp_regex, "errors_"), "")

      "#{Time.zone.now.strftime('%F_%H-%M-%S')}_errors_#{base_filename}"
    end

    def original_filename
      @original_filename ||= recommendations_upload.file.blob.filename.to_s
    end

    def file
      @file ||= params.dig(:bulk_update_recommendations_upload_form, :file)
    end

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
