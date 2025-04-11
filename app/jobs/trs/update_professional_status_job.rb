# frozen_string_literal: true

module Trs
  class UpdateProfessionalStatusJob < ApplicationJob
    queue_as :trs
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)

      @trainee = trainee

      UpdateProfessionalStatus.call(trainee:)

      if trainee.recommended_for_award? && survey_should_be_scheduled?
        Survey::SendJob.set(wait: Settings.qualtrics.days_delayed.days).perform_later(trainee: trainee, event_type: :award)
      end
    end

  private

    attr_reader :trainee

    def survey_should_be_scheduled?
      # Don't send survey for Assessment Only routes or EYTS awards
      !trainee.assessment_only? && trainee.training_route_manager.award_type != EYTS_AWARD_TYPE
    end
  end
end
