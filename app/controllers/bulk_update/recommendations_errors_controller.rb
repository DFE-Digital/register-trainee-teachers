# frozen_string_literal: true

module BulkUpdate
  class RecommendationsErrorsController < ApplicationController
    before_action :check_for_provider

    def show
      respond_to do |format|
        format.html do
          @recommendations_upload_form = RecommendationsUploadForm.new
          @error_rows_count = recommendations_upload.error_rows.size
          @awardable_rows_count = recommendations_upload.awardable_rows.size
        end

        format.csv do
          send_data(csv_with_errors, filename: csv_with_errors_filename, disposition: :attachment)
        end
      end
    end

  private

    def check_for_provider
      redirect_to(root_path) unless provider.is_a?(Provider)
    end

    def provider
      @provider ||= current_user.organisation
    end

    def recommendations_upload
      @recommendations_upload ||= provider.recommendations_uploads.find(params[:recommendations_upload_id])
    end

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
  end
end
