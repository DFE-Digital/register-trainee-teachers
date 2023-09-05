# frozen_string_literal: true

module Dqt
  class SyncTraineeStateJob < Dqt::BaseJob
    queue_as :dqt_sync
    sidekiq_options retry: 5

    sidekiq_retry_in do |count, exception|
      case exception
      when Client::HttpError
        60 * 30 * (count + 1) # 30 minutes * retry count
      else
        :kill
      end
    end

    def perform(trainee)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      Dqt::SyncState.call(trainee:)
    end
  end
end
