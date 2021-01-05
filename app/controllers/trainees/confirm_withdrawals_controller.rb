# frozen_string_literal: true

module Trainees
  class ConfirmWithdrawalsController < ApplicationController
    def show
      authorize trainee
    end

    def update
      authorize trainee
      flash[:success] = "Trainee withdrawn"
      redirect_to edit_trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.find(params[:trainee_id])
    end
  end
end
