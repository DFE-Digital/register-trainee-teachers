# frozen_string_literal: true

module Trainees
  class ConfirmDeferralsController < ApplicationController
    def show
      authorize trainee
    end

    def update
      authorize trainee

      DeferJob.perform_later(trainee.id)

      flash[:success] = "Trainee deferred"
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
