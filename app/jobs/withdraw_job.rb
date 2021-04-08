# frozen_string_literal: true

class WithdrawJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee)
    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::REJECTED,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::REJECTED,
      trainee: trainee,
      entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )

    Dttp::WithdrawTrainee.call(trainee: trainee)
  end
end
