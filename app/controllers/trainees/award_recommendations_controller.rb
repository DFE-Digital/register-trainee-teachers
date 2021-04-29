# frozen_string_literal: true

module Trainees
  class AwardRecommendationsController < ApplicationController
    before_action :authorize_trainee

    def create
      if OutcomeDateForm.new(trainee).save!
        trainee.recommend_for_award!

        RecommendForAwardJob.perform_later(trainee)
        RetrieveAwardJob.perform_with_default_delay(trainee)

        redirect_to recommended_trainee_outcome_details_path(trainee)
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee, :recommend_for_award?)
    end
  end
end
