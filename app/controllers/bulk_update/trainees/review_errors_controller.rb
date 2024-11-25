# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class ReviewErrorsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @bulk_update_trainee_upload = policy_scope(BulkUpdate::TraineeUpload)
          .includes(:row_errors).find(params[:id])

        @bulk_add_trainee_upload_form = BulkUpdate::BulkAddTraineesUploadForm.new(
          provider: current_user.organisation,
        )

        authorize(@bulk_update_trainee_upload)

        respond_to do |format|
          format.html { render(:show) }
          format.csv do
            send_data(
              Exports::BulkTraineeUploadExport.call(trainee_upload: @bulk_update_trainee_upload),
              filename: "trainee-upload-errors-#{@bulk_update_trainee_upload.id}.csv",
              disposition: :attachment,
            )
          end
        end
      end

    private

      def organisation
        @organisation ||= current_user.organisation
      end
    end
  end
end
