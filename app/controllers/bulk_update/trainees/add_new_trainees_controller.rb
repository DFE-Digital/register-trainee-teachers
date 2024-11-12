# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class AddNewTraineesController < ApplicationController
      before_action { check_for_provider }
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @bulk_add_trainee_form = BulkUpdate::BulkAddTraineesForm.new(
          provider: organisation,
        )
      end

      def create
        @bulk_add_trainee_form = BulkUpdate::BulkAddTraineesForm.new(
          provider: organisation,
          file: file,
        )

        if @bulk_add_trainee_form.valid?
          upload = @bulk_add_trainee_form.save
          SendCsvSubmittedForProcessingEmailService.call(user: current_user, upload: upload)
          redirect_to(bulk_update_trainees_status_path(upload.id))
        else
          render(:show)
        end
      end

      def status
        @bulk_update_trainee_upload = organisation.bulk_update_trainee_uploads.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to(not_found_path)
      end

    private

      def file
        @file ||= params.dig(:bulk_update_bulk_add_trainees_form, :file)
      end

      def organisation
        @organisation ||= current_user.organisation
      end

      def check_for_provider
        redirect_to(root_path) unless organisation.is_a?(Provider)
      end
    end
  end
end
