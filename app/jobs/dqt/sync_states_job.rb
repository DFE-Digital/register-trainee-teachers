# frozen_string_literal: true

module Dqt
  class SyncStatesJob < ApplicationJob
    queue_as :default
    retry_on Client::HttpError

    BATCH_SIZE = 100
    INTERVAL = 30.seconds

    def perform
      return unless FeatureService.enabled?(:integrate_with_dqt)

      # DQT have a validation on length of TRN
      trainees = Trainee.trn_received
                        .imported_from_hesa
                        .where("length(trn) = 7")
                        .limit(Settings.dqt.trainee_sync_state_limit)

      trainees.find_in_batches(batch_size: BATCH_SIZE).with_index do |group, batch|
        Dqt::SyncStatesBatchJob.set(wait: INTERVAL * batch).perform_later(group.pluck(:id))
      end
    end
  end
end
