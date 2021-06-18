# frozen_string_literal: true

class RecommendForAwardJob < ApplicationJob
  queue_as :default
  retry_on Dttp::Client::HttpError

  def perform(trainee)
    Dttp::RecommendForAward.call(trainee: trainee)

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::STANDARDS_MET,
      trainee: trainee,
      entity_type: ::Dttp::UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
    )

    Dttp::UpdateTraineeStatus.call(
      status: DttpStatuses::STANDARDS_MET,
      trainee: trainee,
      entity_type: ::Dttp::UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
    )
  end
end
