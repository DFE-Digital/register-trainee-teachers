# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class UploadsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def index
        @bulk_update_trainee_uploads = policy_scope(
          BulkUpdate::TraineeUpload,
        ).current_academic_cycle.not_cancelled_or_uploaded.includes(:file_attachment)

        authorize(@bulk_update_trainee_uploads)
      end

      def show
        authorize(bulk_update_trainee_upload)

        render
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

        if @bulk_add_trainee_upload_form.save
          redirect_to(
            bulk_update_add_trainees_upload_path(@bulk_add_trainee_upload_form.upload),
          )
        else
          render(:new)
        end
      end

      def destroy
        authorize(bulk_update_trainee_upload).cancel!

        redirect_to(bulk_update_path, flash: { success: t(".success") })
      end

      def bulk_add_trainee_upload_form
        @bulk_add_trainee_upload_form ||=
          BulkUpdate::BulkAddTraineesUploadForm.new(
            provider: current_user.organisation,
          )
      end

      helper_method :bulk_add_trainee_upload_form

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||=
          policy_scope(BulkUpdate::TraineeUpload).includes(:row_errors).find(params[:id])
      end

      def upload_params
        params.fetch(:bulk_update_bulk_add_trainees_upload_form, {}).permit(:file)
      end
    end
  end
end
