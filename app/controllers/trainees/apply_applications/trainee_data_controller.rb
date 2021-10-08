# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class TraineeDataController < ApplicationController
      before_action :authorize_trainee
      before_action :require_review_acknowledgement, only: :update

      def edit
        page_tracker.save_as_origin!
        @trainee = trainee
        @trainee_data_form = trainee_data_form
        @invalid_data_view = invalid_data_view
      end

      def update
        @trainee = trainee
        @trainee_data_form = trainee_data_form
        @invalid_data_view = ApplyInvalidDataView.new(trainee.apply_application)

        if @trainee_data_form.save
          redirect_to(trainee_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def trainee_data_form
        @trainee_data_form ||= ::ApplyApplications::TraineeDataForm.new(trainee)
      end

      def invalid_data_view
        @invalid_data_view ||= ApplyInvalidDataView.new(trainee.apply_application, degrees_sort_order: trainee.degrees.pluck(:slug))
      end

      def authorize_trainee
        authorize(trainee)
      end

      def require_review_acknowledgement
        redirect_to(review_draft_trainee_path(trainee)) unless marked_as_reviewed?
      end

      def marked_as_reviewed?
        params[:apply_applications_trainee_data_form][:mark_as_reviewed] == "1"
      end
    end
  end
end
