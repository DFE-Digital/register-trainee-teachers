# frozen_string_literal: true

module Dqt
  class SyncStatesJob < ApplicationJob
    queue_as :dqt_sync
    retry_on Client::HttpError

    def perform(batch_size = 100, interval = 30.seconds)
      return unless FeatureService.enabled?(:integrate_with_dqt)

      dqt_trn_validation_clause = "length(trn) = 7"

      trainees = Trainee.trn_received
                        .imported_from_hesa
                        .where(dqt_trn_validation_clause)

      trainees.find_in_batches(batch_size:).with_index do |group, batch|
        # The API rate limit is 300 requests per minute so by default we're
        # kicking off 100 trainees every 30 seconds to stay within that.
        Dqt::SyncStatesBatchJob.set(wait: interval * batch).perform_later(group.pluck(:id))
      end
    end
  end
end
