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
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end

    def trainee_params
      params.require(:trainee).permit(:trainee_id)
    end
  end
end
