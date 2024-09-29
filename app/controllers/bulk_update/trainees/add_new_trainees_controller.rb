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

        @bulk_add_trainee_form.save

        redirect_to(bulk_update_trainees_status_path)
      end

      def status; end

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
