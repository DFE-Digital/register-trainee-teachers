# frozen_string_literal: true

module Dqt
  class RecommendForAwardJob < ApplicationJob
    queue_as :dqt
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      award_date = RecommendForAward.call(trainee:)

      if award_date
        trainee.award_qts!(award_date)
        Trainees::Update.call(trainee: trainee, update_dqt: false)
      else
        raise(
          DqtNoAwardDateError,
          "failed to retrieve award date from DQT for trainee: #{trainee.id}",
        )
      end
    end
  end
end
