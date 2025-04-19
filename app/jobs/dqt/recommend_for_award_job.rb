# frozen_string_literal: true

module Dqt
  class RecommendForAwardJob < Dqt::BaseJob
    queue_as :dqt
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      @trainee = trainee

      award_date = RecommendForAward.call(trainee:)

      if award_date
        trainee.award_qts!(award_date)
        Survey::SendJob.set(wait: Settings.qualtrics.days_delayed.days).perform_later(trainee: trainee, event_type: :award) if survey_should_be_scheduled?
        Trainees::Update.call(trainee: trainee, update_dqt: false)
      else
        raise(
          DqtNoAwardDateError,
          "failed to retrieve award date from DQT for trainee: #{trainee.id}",
        )
      end
    end

  private

    attr_reader :trainee

    def survey_should_be_scheduled?
      # Don't send survey for Assessment Only routes or EYTS awards
      !(trainee.assessment_only? || trainee.training_route_manager.award_type == EYTS_AWARD_TYPE)
    end
  end
end
