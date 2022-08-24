# frozen_string_literal: true

module Dqt
  class SyncTraineeStateJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      Dqt::SyncState.call(trainee: trainee)
    end
  end
end
