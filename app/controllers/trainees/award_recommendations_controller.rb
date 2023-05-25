# frozen_string_literal: true

module Trainees
  class AwardRecommendationsController < BaseController
    def create
      if OutcomeDateForm.new(trainee).save! && trainee.submission_ready?
        trainee.recommend_for_award!

        Dqt::RecommendForAwardJob.perform_later(trainee)

        redirect_to(recommended_trainee_outcome_details_path(trainee))
      end
    end

  private

    def authorize_trainee
      authorize(trainee, :recommend_for_award?)
    end
  end
end
