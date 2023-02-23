# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTeachersBatchJob do
    let!(:trainee) { create(:trainee) }

    before do
      enable_features("dqt_import.sync_teachers")
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    end

    after { ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true }

    it "enqueues job per trainee" do
      expect {
        described_class.perform_now([trainee.id])
      }.to enqueue_job(SyncTeacherJob).with(trainee)
    end
  end
end
