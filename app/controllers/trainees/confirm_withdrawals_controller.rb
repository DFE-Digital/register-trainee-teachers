# frozen_string_literal: true

module Trainees
  class ConfirmWithdrawalsController < ApplicationController
    def show
      authorize trainee
    end

    def update
      authorize trainee

      trainee.withdraw!
      WithdrawJob.perform_later(trainee.id)

      flash[:success] = "Trainee withdrawn"
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
