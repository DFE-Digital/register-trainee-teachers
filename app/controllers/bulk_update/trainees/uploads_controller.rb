# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class UploadsController < ApplicationController
      before_action { check_for_provider }
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
      end

      def new
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: organisation,
        )
      end

      def create
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: organisation,
          file: file,
        )

        if @bulk_add_trainee_upload_form.valid?
          # TODO: Dry run method
          upload = @bulk_add_trainee_upload_form.save

          redirect_to(bulk_update_trainees_upload_path(upload))
        else
          render(:new)
        end
      end

    private

      def file
        @file ||= params.dig(:bulk_update_bulk_add_trainees_upload_form, :file)
      end

      def organisation
        @organisation ||= current_user.organisation
      end

      def check_for_provider
        redirect_to(root_path) unless current_user.hei_provider?
      end
    end
  end
end
