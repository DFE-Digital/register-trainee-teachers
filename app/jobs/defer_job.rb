# frozen_string_literal: true

class DeferJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee)
    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::DEFERRED,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::DEFERRED,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )

    Dttp::CreateDormancy.call(trainee: trainee)
  end
end
