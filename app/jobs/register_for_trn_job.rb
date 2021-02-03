# frozen_string_literal: true

class RegisterForTrnJob < ApplicationJob
  queue_as :default
  retry_on Dttp::BatchRequest::Error

  def perform(trainee_id, trainee_creator_dttp_id)
    @trainee = Trainee.find(trainee_id)

    Dttp::RegisterForTrn.call(trainee: trainee, trainee_creator_dttp_id: trainee_creator_dttp_id)

    ChangeTraineeStatusJob.perform_later(
      contact_dttp_id,
      DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
      Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    ChangeTraineeStatusJob.perform_later(
      placement_assignment_dttp_id,
      DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
      Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )
  end

private

  attr_reader :trainee

  def contact_dttp_id
    trainee.dttp_id
  end

  def placement_assignment_dttp_id
    trainee.placement_assignment_dttp_id
  end
end
