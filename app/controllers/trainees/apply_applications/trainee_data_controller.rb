# frozen_string_literal: true

module Trainees
  module ApplyApplications
    class TraineeDataController < ApplicationController
      before_action :authorize_trainee

      def edit
        page_tracker.save_as_origin!
        @trainee_data_form = ::ApplyApplications::TraineeDataForm.new(trainee)
      end

      def update
        if params[:apply_applications_trainee_data_form][:mark_as_reviewed] == "1"
          @trainee_data_form = ::ApplyApplications::TraineeDataForm.new(trainee)

          if @trainee_data_form.save
            redirect_to trainee_path(trainee)
          else
            render :edit
          end
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
