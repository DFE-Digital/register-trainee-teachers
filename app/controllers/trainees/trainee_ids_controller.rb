# frozen_string_literal: true

module Trainees
  class TraineeIdsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @training_details = TrainingDetailsForm.new(trainee)
    end

    def update
      @training_details = TrainingDetailsForm.new(trainee, validate_commencement_date: false)
      @training_details.assign_attributes(trainee_params)

      if @training_details.save
        redirect_to trainee_trainee_id_confirm_path(trainee)
      else
        render :edit
      end
    end

    def confirm
      page_tracker.save_as_origin!
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:training_details_form).permit(:trainee_id)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
