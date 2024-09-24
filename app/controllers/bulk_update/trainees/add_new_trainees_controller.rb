# frozen_string_literal: true

module BulkUpdate
  module Trainees
    class AddNewTraineesController < ApplicationController
      before_action { check_for_provider }
      before_action { require_feature_flag(:bulk_add_trainees) }

      def show
        @navigation_view = ::Funding::NavigationView.new(organisation:)
      end

      def create
        # Validate the uploaded CSV

        redirect_to(bulk_update_trainees_status_path)
      end

      def status
        @navigation_view = ::Funding::NavigationView.new(organisation:)
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
