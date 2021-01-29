# frozen_string_literal: true

class ChangeTraineeStatusJob < ApplicationJob
  queue_as :default
  retry_on Dttp::UpdateTraineeStatus::Error

  def perform(entity_id, status, entity_type)
    Dttp::UpdateTraineeStatus.call(status: status, entity_id: entity_id, entity_type: entity_type)
  end
end
