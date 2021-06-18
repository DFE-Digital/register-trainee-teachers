# frozen_string_literal: true

class ReinstateJob < ApplicationJob
  queue_as :default
  retry_on Dttp::Client::HttpError

  def perform(trainee)
    status = trainee.trn.present? ? DttpStatuses::YET_TO_COMPLETE_COURSE : DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED

    Dttp::UpdateTraineeStatus.call(
      status: status,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: status,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )

    Dttp::UpdateDormancy.call(trainee: trainee)
  end
end
