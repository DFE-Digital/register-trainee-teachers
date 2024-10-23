# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class AddNewTraineesController < ApplicationController
      before_action { check_for_provider }
      before_action { require_feature_flag(:bulk_add_trainees) }

      # new?
      def show
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: organisation,
        )
      end

      # create?
      def upload
        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: organisation,
          file: file,
        )

        if @bulk_add_trainee_upload_form.valid?
          # TODO: Dry run method
          upload = @bulk_add_trainee_upload_form.save
          redirect_to(bulk_update_trainees_review_path(upload.id))
        else
          render(:show)
        end
      end

      # show?
      def review
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
      end

      def submit
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
        @bulk_add_trainee_submit_form = BulkUpdate::BulkAddTraineesSubmitForm.new(upload: @bulk_update_trainee_upload)
        @bulk_add_trainee_submit_form.save

        # TODO: Handle failures/errors when saving

        redirect_to(bulk_update_trainees_status_path(@bulk_update_trainee_upload.id))
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
      end

      def status
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
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
