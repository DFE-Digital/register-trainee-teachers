# frozen_string_literal: true

module Trainees
  class AwardRecommendationsController < BaseController
    def create
      if OutcomeDateForm.new(trainee).save! && trainee.submission_ready?
        trainee.recommend_for_award!

        if FeatureService.enabled?(:persist_to_dttp)
          Dttp::RecommendForAwardJob.perform_later(trainee)
          Dttp::RetrieveAwardJob.perform_with_default_delay(trainee)
        end

        if FeatureService.enabled?(:integrate_with_dqt)
          Dqt::RecommendForAwardJob.perform_later(trainee)
        end

        redirect_to(recommended_trainee_outcome_details_path(trainee))
      end
    end

  private

    def authorize_trainee
      authorize(trainee, :recommend_for_award?)
    end
  end
end
