# frozen_string_literal: true

module Dttp
  class WithdrawJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      UpdateTraineeStatus.call(
        status: DttpStatuses::LEFT_COURSE_BEFORE_END,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      UpdateTraineeStatus.call(
        status: DttpStatuses::LEFT_COURSE_BEFORE_END,
        trainee: trainee,
        entity_type: UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )

      WithdrawTrainee.call(trainee: trainee)
    end
  end
end
