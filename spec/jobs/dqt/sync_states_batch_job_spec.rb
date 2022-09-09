# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesBatchJob do
    let!(:trainee) { create(:trainee) }

    before { ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false }

    after { ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true }

    it "enqueues a SyncTraineeStateJob per trainee", feature_integrate_with_dqt: true do
      expect {
        described_class.perform_now([trainee.id])
      }.to enqueue_job(SyncTraineeStateJob).with(trainee)
    end
  end
end
