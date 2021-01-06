# frozen_string_literal: true

module Trainees
  class QtsRecommendationsController < ApplicationController
    def create
      authorize trainee

      RecommendForQtsJob.perform_later(trainee.id)

      redirect_to recommended_trainee_outcome_details_path(trainee_id: trainee.id)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
