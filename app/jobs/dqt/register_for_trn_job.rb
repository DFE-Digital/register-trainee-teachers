# frozen_string_literal: true

module Dqt
  class RegisterForTrnJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :default

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      RegisterForTrn.call(trainee: trainee)

      ChangeTraineeStatusJob.perform_later(
        trainee,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      ChangeTraineeStatusJob.perform_later(
        trainee,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )
    end
  end
end
