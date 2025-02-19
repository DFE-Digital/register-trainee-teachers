# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class SubmissionsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def create
        @bulk_add_trainee_submit_form = BulkUpdate::BulkAddTraineesSubmitForm.new(
          upload: authorize(
            bulk_update_trainee_upload,
            policy_class: BulkUpdate::Submissions::TraineeUploadPolicy,
          ),
        )

        @bulk_add_trainee_submit_form.save

        SendCsvSubmittedForProcessingEmailService.call(upload: bulk_update_trainee_upload)

        redirect_to(bulk_update_add_trainees_upload_path(bulk_update_trainee_upload))
      end

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||= policy_scope(BulkUpdate::TraineeUpload).find(params[:id])
      end
    end
  end
end
