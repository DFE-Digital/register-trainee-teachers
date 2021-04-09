# frozen_string_literal: true

class ChangeTraineeStatusJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(trainee, status, entity_type)
    Dttp::UpdateTraineeStatus.call(status: status, trainee: trainee, entity_type: entity_type)
  end
end
