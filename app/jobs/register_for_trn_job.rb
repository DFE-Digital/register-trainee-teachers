# frozen_string_literal: true

class RegisterForTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::Client::HttpError

  def perform(trainee, created_by_dttp_id)
    Dttp::RegisterForTrn.call(trainee: trainee, created_by_dttp_id: created_by_dttp_id)

    ChangeTraineeStatusJob.perform_later(
      trainee,
      DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
      Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    ChangeTraineeStatusJob.perform_later(
      trainee,
      DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
      Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )
  end
end
