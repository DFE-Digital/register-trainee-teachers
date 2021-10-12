# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class TraineeDataController < BaseController
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

      def trainee_data_form
        @trainee_data_form ||= ::ApplyApplications::TraineeDataForm.new(trainee)
      end

      def invalid_data_view
        @invalid_data_view ||= ApplyInvalidDataView.new(trainee.apply_application, degrees_sort_order: trainee.degrees.pluck(:slug))
      end

      def require_review_acknowledgement
        redirect_to(trainee_review_drafts_path(trainee)) unless marked_as_reviewed?
      end

      def marked_as_reviewed?
        params[:apply_applications_trainee_data_form][:mark_as_reviewed] == "1"
      end
    end
  end
end
