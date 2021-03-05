# frozen_string_literal: true

module Trainees
  class ConfirmReinstatementsController < ApplicationController
    before_action :authorize_trainee

    def show
      page_tracker.save_as_origin!
    end

    def update
      trainee.trn.present? ? trainee.trn_received! : trainee.submit_for_trn!

      ReinstateJob.perform_later(trainee.id)

      flash[:success] = "Trainee reinstated"
      redirect_to trainee_path(trainee)
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
