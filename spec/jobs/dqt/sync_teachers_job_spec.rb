# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTeachersJob do
    let!(:trainee1) { create(:trainee, :trn_received) }
    let!(:trainee2) { create(:trainee, :trn_received) }

    before do
      enable_features("dqt_import.sync_teachers")
    end

    it "queues up at intervals with the trainee batches" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(1)
        expect(SyncTeachersBatchJob).to have_been_enqueued.with([trainee1.id])
        expect(SyncTeachersBatchJob).to have_been_enqueued.at(30.seconds.from_now).with([trainee2.id])
      end
    end
  end
end
