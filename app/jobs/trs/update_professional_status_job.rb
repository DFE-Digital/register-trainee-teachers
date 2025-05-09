# frozen_string_literal: true

module Trs
  class UpdateProfessionalStatusJob < ApplicationJob
    queue_as :trs
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)

      @trainee = trainee

      UpdateProfessionalStatus.call(trainee:)

      # Handle the award state transition when the trainee is recommended for award
      # TRS returns 204 No Content, so we need to use our own award date
      if trainee.recommended_for_award? && trainee.outcome_date.present?
        trainee.award_qts!(trainee.outcome_date)
        Trainees::Update.call(trainee: trainee, update_dqt: false)
        Survey::SendJob.set(wait: Settings.qualtrics.days_delayed.days).perform_later(trainee: trainee, event_type: :award) if survey_should_be_scheduled?
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
