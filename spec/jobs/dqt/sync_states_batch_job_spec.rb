# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesBatchJob do
    let!(:trainee) { create(:trainee) }

    around do |example|
      original_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      example.run
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = original_perform_enqueued_jobs
    end

    it "enqueues a SyncTraineeStateJob per trainee", feature_integrate_with_dqt: true do
      expect {
        described_class.perform_now([trainee.id])
      }.to enqueue_job(SyncTraineeStateJob).with(trainee)
    end
  end
end
