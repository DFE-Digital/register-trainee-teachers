# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class UploadsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        authorize(bulk_update_trainee_upload)
      end

      def new
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: current_user.organisation,
        )

        authorize(@bulk_add_trainee_upload_form.upload)
      end

      def create
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: current_user.organisation,
          file: upload_params[:file],
        )

        authorize(@bulk_add_trainee_upload_form.upload)

        if @bulk_add_trainee_upload_form.valid?
          # TODO: Dry run method
          upload = @bulk_add_trainee_upload_form.save

          redirect_to(bulk_update_trainees_upload_path(upload), flash: { success: t(".success") })
        else
          render(:new)
        end
      end

      def destroy
        authorize(bulk_update_trainee_upload).cancelled!

        redirect_to(bulk_update_path, flash: { success: t(".success") })
      end

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||= policy_scope(BulkUpdate::TraineeUpload)
          .includes(:row_errors).find(params[:id])
      end

      def upload_params
        params.fetch(:bulk_update_bulk_add_trainees_upload_form, {}).permit(:file)
      end
    end
  end
end
