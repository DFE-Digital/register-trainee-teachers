# frozen_string_literal: true

module Dqt
  class RecommendForAwardJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      if trainee.hesa_record?
        message = "Trainee id: #{trainee.id}, slug: #{trainee.slug} has been recommended for award but is a HESA trainee"
        username = "Register Trainee Teachers: Job Failure"
        SlackNotifierService.call(message: message, username: username)
      else
        award_date = RecommendForAward.call(trainee: trainee)

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
end
