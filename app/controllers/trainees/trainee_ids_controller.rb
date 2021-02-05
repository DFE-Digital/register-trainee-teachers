# frozen_string_literal: true

module Trainees
  class TraineeIdsController < ApplicationController
    def edit
      authorize trainee
    end

    def update
      authorize trainee
      trainee.update!(trainee_params)
      redirect_to confirm_trainee_trainee_id_path(trainee)
    end

    def confirm
      authorize trainee
      page_tracker.save_as_origin!
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.require(:trainee).permit(:trainee_id)
    end
  end
end
