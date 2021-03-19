# frozen_string_literal: true

module Trainees
  class TraineeIdsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @training_details = TraineeIdForm.new(trainee)
    end

    def update
      @training_details = TraineeIdForm.new(trainee, trainee_params)

      save_strategy = trainee.draft? ? :save! : :stash

      if @training_details.public_send(save_strategy)
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
      params.require(:trainee_id_form).permit(:trainee_id)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
