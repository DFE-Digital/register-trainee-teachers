# frozen_string_literal: true

module SystemAdmin
  class UploadsController < ApplicationController
    before_action :set_upload, only: %i[show destroy]

    def index
      @uploads = if params[:search].present?
                   Upload.search_by_name(params[:search])
                 else
                   Upload.all
                 end
    end

    def show; end

    def new
      @upload = Upload.new
    end

    def create
      @upload = Upload.new(upload_params)

      if @upload.save
        redirect_to(@upload, notice: "File successfully uploaded.")
      else
        render(:new)
      end
    rescue ActionController::ParameterMissing
      @upload = Upload.new
      @upload.errors.add(:file, "Please select a file")
      render(:new)
    end

    def destroy
      @upload.destroy!
      redirect_to(uploads_url, notice: "Upload destroyed")
    end

  private

    def set_upload
      @upload = Upload.find(params[:id])
    end

    def upload_params
      params.require(:upload).permit(:file).merge(
        user: current_user,
        name: params.dig(:upload, :file)&.original_filename,
      )
    end
  end
end
