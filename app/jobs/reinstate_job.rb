# frozen_string_literal: true

class ReinstateJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)

    status = trainee.trn.present? ? DttpStatuses::YET_TO_COMPLETE_COURSE : DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED

    Dttp::UpdateTraineeStatus.call(
      status: status,
      entity_id: trainee.dttp_id,
      entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: status,
      entity_id: trainee.placement_assignment_dttp_id,
      entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )

    Dttp::UpdateDormancy.call(trainee: trainee)
  end
end
