# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class TraineeDataController < BaseController
      before_action :require_review_acknowledgement, only: :update
      before_action :load_invalid_data_view

      def edit
        page_tracker.save_as_origin!
      end

      def update
        if @trainee_data_form.save
          redirect_to(trainee_path(trainee))
        else
          render(:edit)
        end
      end

    private

      def load_invalid_data_view
        @invalid_data_view = ::ApplyApplications::InvalidTraineeDataView.new(trainee, trainee_data_form)
      end

      def trainee_data_form
        @trainee_data_form ||= ::ApplyApplications::TraineeDataForm.new(trainee, include_degree_id: true)
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
