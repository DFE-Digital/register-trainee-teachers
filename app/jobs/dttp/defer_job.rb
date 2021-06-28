# frozen_string_literal: true

module Dttp
  class DeferJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      UpdateTraineeStatus.call(
        status: DttpStatuses::DEFERRED,
        trainee: trainee,
        entity_type: Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      UpdateTraineeStatus.call(
        status: DttpStatuses::DEFERRED,
        trainee: trainee,
        entity_type: Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )

      CreateDormancy.call(trainee: trainee)
    end
  end
end
