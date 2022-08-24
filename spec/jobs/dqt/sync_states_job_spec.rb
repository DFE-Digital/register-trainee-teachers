# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesJob do
    let!(:trainee) { create(:trainee, state, :imported_from_hesa) }

    subject(:sync_states_job) { described_class.perform_now }

    before do
      enable_features(:integrate_with_dqt)
    end

    context "with no trn_received trainees" do
      let(:state) { "awarded" }

      it "doesn't queue a batch job" do
        expect {
          sync_states_job
        }.not_to enqueue_job(SyncStatesBatchJob)
      end
    end

    context "with trn_received trainees" do
      let(:state) { "trn_received" }

      it "calls the SyncStatesBatchJob" do
        expect {
          sync_states_job
        }.to enqueue_job(SyncStatesBatchJob).with([trainee.id])
      end

      context "but not from HESA" do
        before do
          trainee.update!(hesa_id: nil)
        end

        it "doesn't queue a batch job" do
          expect {
            sync_states_job
          }.not_to enqueue_job(SyncStatesBatchJob)
        end
      end

      context "but the TRN is not 7-digits" do
        before do
          trainee.update!(trn: "123456")
        end

        it "doesn't queue a batch job" do
          expect {
            sync_states_job
          }.not_to enqueue_job(SyncStatesBatchJob)
        end
      end

      context "with more trainees" do
        let!(:trainee2) { create(:trainee, :trn_received, :imported_from_hesa) }

        before do
          stub_const("Dqt::SyncStatesJob::BATCH_SIZE", 1)
        end

        it "queues up SyncStatesBatchJob at intervals with the trainee batches" do
          Timecop.freeze(Time.zone.now) do
            described_class.perform_now
            expect(SyncStatesBatchJob).to have_been_enqueued.with([trainee.id])
            expect(SyncStatesBatchJob).to have_been_enqueued.at(30.seconds.from_now)
              .with([trainee2.id])
          end
        end
      end
    end
  end
end
