# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTeachersBatchJob do
    let!(:trainee) { create(:trainee) }

    before { enable_features("dqt_import.sync_teachers") }

    around do |example|
      original_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
      example.run
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = original_perform_enqueued_jobs
    end

    after { disable_features("dqt_import.sync_teachers") }

    it "enqueues job per trainee" do
      expect {
        described_class.perform_now([trainee.id])
      }.to enqueue_job(SyncTeacherJob).with(trainee)
    end
  end
end
