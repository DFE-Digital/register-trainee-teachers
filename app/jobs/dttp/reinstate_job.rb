# frozen_string_literal: true

module Dttp
  class ReinstateJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      status = trainee.trn.present? ? DttpStatuses::YET_TO_COMPLETE_COURSE : DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED

      UpdateTraineeStatus.call(
        status: status,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      UpdateTraineeStatus.call(
        status: status,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )

      UpdateDormancy.call(trainee: trainee)
    end
  end
end
