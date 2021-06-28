# frozen_string_literal: true

module Dttp
  class RecommendForAwardJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:persist_to_dttp)

      RecommendForAward.call(trainee: trainee)

      UpdateTraineeStatus.call(
        status: DttpStatuses::STANDARDS_MET,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      Dttp::UpdateTraineeStatus.call(
        status: DttpStatuses::STANDARDS_MET,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )
    end
  end
end
