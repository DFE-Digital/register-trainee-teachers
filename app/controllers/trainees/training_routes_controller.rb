# frozen_string_literal: true

module Trainees
  class TrainingRoutesController < ApplicationController
    before_action :ensure_trainee_is_draft!
    before_action :authorize_trainee

    def edit; end

    def update
      trainee.update!(trainee_params)
      redirect_to page_tracker.last_origin_page_path || trainee_path(trainee)
    end

  private

    def trainee_params
      params.require(:trainee).permit(:training_route)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end
