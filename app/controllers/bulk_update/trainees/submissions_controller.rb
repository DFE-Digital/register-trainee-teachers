# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class SubmissionsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        authorize(
          bulk_update_trainee_upload,
          policy_class: BulkUpdate::Submissions::TraineeUploadPolicy,
        )
      end

      def create
        @bulk_add_trainee_submit_form = BulkUpdate::BulkAddTraineesSubmitForm.new(
          upload: authorize(
            bulk_update_trainee_upload,
            policy_class: BulkUpdate::Submissions::TraineeUploadPolicy,
          ),
        )

        @bulk_add_trainee_submit_form.save

        # TODO: Handle failures/errors when saving

        SendCsvSubmittedForProcessingEmailService.call(user: current_user, upload: bulk_update_trainee_upload)
        redirect_to(bulk_update_trainees_submission_path(bulk_update_trainee_upload))
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
      end

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||= policy_scope(BulkUpdate::TraineeUpload).find(params[:id])
      end
    end
  end
end
