# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class SubmissionsController < ApplicationController
      before_action { check_for_provider }
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find_by(id: params[:id])

        redirect_to(not_found_path) unless @bulk_update_trainee_upload
      end

      def create
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
        @bulk_add_trainee_submit_form = BulkUpdate::BulkAddTraineesSubmitForm.new(upload: @bulk_update_trainee_upload)
        @bulk_add_trainee_submit_form.save

        # TODO: Handle failures/errors when saving

        redirect_to(bulk_update_trainees_submission_path(@bulk_update_trainee_upload))
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
      end

    private

      def organisation
        @organisation ||= current_user.organisation
      end

      def check_for_provider
        redirect_to(root_path) unless organisation.is_a?(Provider)
      end
    end
  end
end
