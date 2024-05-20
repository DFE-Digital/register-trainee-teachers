# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesJob do
    let!(:trainee) { create(:trainee, state, :imported_from_hesa) }

    subject(:sync_states_job) { described_class.perform_now }

    before do
      enable_features(:integrate_with_dqt)
    end

    after do
      disable_features(:integrate_with_dqt)
    end

    context "with no trn_received trainees" do
      let(:state) { "awarded" }

      it "doesn't queue a batch job" do
        expect {
          sync_states_job
        }.not_to have_enqueued_job(SyncStatesBatchJob)
      end
    end

    context "with trn_received trainees" do
      let(:state) { "trn_received" }

      it "calls the SyncStatesBatchJob" do
        expect {
          sync_states_job
        }.to have_enqueued_job(SyncStatesBatchJob).with([trainee.id])
      end

      context "but not from HESA" do
        before { trainee.manual_record! }

        it "doesn't queue a batch job" do
          expect {
            sync_states_job
          }.not_to have_enqueued_job(SyncStatesBatchJob)
        end
      end

      context "but the TRN is not 7-digits" do
        before { trainee.update!(trn: "123456") }

        it "doesn't queue a batch job" do
          expect {
            sync_states_job
          }.not_to have_enqueued_job(SyncStatesBatchJob)
        end
      end

      context "with more trainees" do
        let!(:trainee2) { create(:trainee, :trn_received, :imported_from_hesa) }

        it "queues up SyncStatesBatchJob at intervals with the trainee batches" do
          Timecop.freeze(Time.zone.now) do
            described_class.perform_now(1)
            expect(SyncStatesBatchJob).to have_been_enqueued.exactly(:once).with([trainee.id])
            expect(SyncStatesBatchJob).to have_been_enqueued.exactly(:once).at(30.seconds.from_now).with([trainee2.id])
          end
        end
      end
    end
  end
end
