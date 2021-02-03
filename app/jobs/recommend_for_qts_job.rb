# frozen_string_literal: true

class RecommendForQtsJob < ApplicationJob
  queue_as :default
  retry_on Dttp::RecommendForQTS::Error
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)

    Dttp::RecommendForQTS.call(trainee: trainee)

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::STANDARDS_MET,
      entity_id: trainee.dttp_id,
      entity_type: ::Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::STANDARDS_MET,
      entity_id: trainee.placement_assignment_dttp_id,
      entity_type: ::Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )
  end
end
