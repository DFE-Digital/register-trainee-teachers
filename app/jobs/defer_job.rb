# frozen_string_literal: true

class DeferJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee_id)
    trainee = Trainee.find(trainee_id)
    Dttp::UpdateTraineeStatus.call(status: DttpStatuses::DEFERRED,
                                   entity_id: trainee.placement_assignment_dttp_id,
                                   entity_type: :placement_assignment)
  end
end
