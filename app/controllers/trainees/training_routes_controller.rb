# frozen_string_literal: true

module Trainees
  class TrainingRoutesController < BaseController
    prepend_before_action :ensure_trainee_is_draft!

    def edit; end

    def update
      trainee.update_training_route!(training_route)
      redirect_url
    end

  private

    def redirect_url
      redirect_to(page_tracker.last_origin_page_path || trainee_path(trainee))
    end

    def trainee_params
      params.require(:trainee).permit(:training_route)
    end

    def training_route
      trainee_params["training_route"]
    end
  end
end
