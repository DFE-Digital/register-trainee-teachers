# frozen_string_literal: true

module Dttp
  class RegisterForTrnJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    include ClockoverDependent

    def perform(trainee, created_by_dttp_id)
      @trainee = trainee
      @created_by_dttp_id = created_by_dttp_id

      return unless FeatureService.enabled?(:persist_to_dttp)

      if before_clockover? && trainee_is_not_assessment_only?
        requeue_after_clockover
        return
      end

      RegisterForTrn.call(trainee: trainee, created_by_dttp_id: created_by_dttp_id)

      ChangeTraineeStatusJob.perform_later(
        trainee,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        UpdateTraineeStatus::CONTACT_ENTITY_TYPE,
      )

      ChangeTraineeStatusJob.perform_later(
        trainee,
        DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED,
        UpdateTraineeStatus::PLACEMENT_ASSIGNMENT_ENTITY_TYPE,
      )
    end

  private

    attr_reader :trainee, :created_by_dttp_id

    def requeue_after_clockover
      self.class.set(wait_until: clockover_date).perform_later(trainee, created_by_dttp_id)
    end

    def trainee_is_not_assessment_only?
      !(trainee.assessment_only? || trainee.early_years_assessment_only?)
    end
  end
end
