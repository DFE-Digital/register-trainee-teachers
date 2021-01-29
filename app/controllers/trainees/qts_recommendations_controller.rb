# frozen_string_literal: true

module Trainees
  class QtsRecommendationsController < ApplicationController
    def create
      authorize trainee
      trainee.recommend_for_qts!

      RecommendForQtsJob.perform_later(trainee.id)
      RetrieveQtsJob.set(wait: RetrieveQtsJob::POLL_DELAY).perform_later(trainee.id)

      redirect_to recommended_trainee_outcome_details_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end
  end
end
