# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class ReviewErrorsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      # TODO: integrate with Pundit policy

      def show
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find_by(id: params[:id])

        redirect_to(not_found_path) unless @bulk_update_trainee_upload.present?

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
