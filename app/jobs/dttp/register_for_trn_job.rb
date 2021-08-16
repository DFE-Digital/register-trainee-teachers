# frozen_string_literal: true

module Dttp
  class RegisterForTrnJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee, created_by_dttp_id)
      return unless FeatureService.enabled?(:persist_to_dttp)

      RegisterForTrn.call(trainee: trainee, created_by_dttp_id: created_by_dttp_id)

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
