# frozen_string_literal: true

module Trs
  class UpdateTraineeJob < ApplicationJob
    sidekiq_options retry: 0
    queue_as :trs

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_trs)
      return unless trainee_updatable?(trainee)

      UpdatePersonPii.call(trainee:)
    end

  private

    def trainee_updatable?(trainee)
      # Reload to ensure we have the latest state
      current_trainee = trainee.reload

      # Must have a TRN and not be in an invalid state
      current_trainee.trn.present? &&
        !Config::INVALID_UPDATE_STATES.include?(current_trainee.state)
    end
  end
end
