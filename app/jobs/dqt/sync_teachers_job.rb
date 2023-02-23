# frozen_string_literal: true

module Dqt
  class SyncTeachersJob < ApplicationJob
    queue_as :dqt_sync

    def perform(batch_size = 500, interval = 30.seconds)
      return unless FeatureService.enabled?("dqt_import.sync_teachers")

      trainees = Trainee.where.not(trn: nil).where("length(trn) = 7").in_training.or(Trainee.deferred)

      trainees.find_in_batches(batch_size:).with_index do |group, batch|
        # The API rate limit is 3000 requests per minute so by default we're
        # kicking off 500 trainees every 30 seconds to stay within that without
        # affecting day-to-day DQT requests from other Register services.
        Dqt::SyncTeachersBatchJob.set(wait: interval * batch).perform_later(group.pluck(:id))
      end
    end
  end
end
