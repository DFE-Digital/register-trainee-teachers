# frozen_string_literal: true

module Dqt
  class SyncStatesBatchJob < Dqt::BaseJob
    queue_as :dqt_sync
    retry_on Client::HttpError

    def perform(trainee_ids)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      Trainee.where(id: trainee_ids).each do |trainee|
        Dqt::SyncTraineeStateJob.perform_later(trainee)
      end
    end
  end
end
