# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ReviewErrorsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @bulk_update_trainee_upload = policy_scope(BulkUpdate::TraineeUpload)
          .includes(:row_errors).find(params[:id])

        authorize(@bulk_update_trainee_upload)

        respond_to do |format|
          format.csv do
            send_data(
              Exports::BulkTraineeUploadExport.call(trainee_upload: @bulk_update_trainee_upload),
              filename: "trainee-upload-errors-#{@bulk_update_trainee_upload.id}.csv",
              disposition: :attachment,
            )
          end
        end
      end
    end
  end
end
