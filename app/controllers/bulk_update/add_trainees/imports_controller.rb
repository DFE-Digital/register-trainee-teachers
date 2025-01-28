# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def new
        @bulk_add_trainees_import_rows_form = BulkUpdate::BulkAddTraineesImportRowsForm.new(
          upload: authorize(
            bulk_update_trainee_upload,
            policy_class: BulkUpdate::Imports::TraineeUploadPolicy,
          ),
        )
      end

      def create
        BulkUpdate::BulkAddTraineesImportRowsForm.new(
          upload: authorize(
            bulk_update_trainee_upload,
            policy_class: BulkUpdate::Imports::TraineeUploadPolicy,
          ),
        ).save

        redirect_to(
          bulk_update_add_trainees_upload_path(
            bulk_update_trainee_upload,
          ), flash: { success: t(".success") }
        )
      end

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||= policy_scope(BulkUpdate::TraineeUpload)
          .find(params[:id])
      end
    end
  end
end
