# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class DetailsController < ApplicationController
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        authorize(
          bulk_update_trainee_upload,
          policy_class: BulkUpdate::Details::TraineeUploadPolicy,
        )
      end

    private

      def bulk_update_trainee_upload
        @bulk_update_trainee_upload ||= policy_scope(
          BulkUpdate::TraineeUpload,
        ).find(params[:id])
      end
    end
  end
end
