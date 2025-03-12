# frozen_string_literal: true

require "rails_helper"

module Trs
  describe RetrieveTrnJob do
    include ActiveJob::TestHelper

    let(:trn) { nil }
    let(:trainee) { create(:trainee, :submitted_for_trn) }
    let(:configured_delay) { 6 }
    let(:configured_poll_timeout_days) { 4 }
    let(:timeout_date) { configured_poll_timeout_days.days.from_now }
    let(:trn_request) { create(:dqt_trn_request, trainee:) }

    before do
      enable_features(:integrate_with_trs)
      allow(RetrieveTrn).to receive(:call).with(trn_request:).and_return(trn)
      allow(Settings.jobs).to receive_messages(poll_delay_hours: configured_delay, max_poll_duration_days: configured_poll_timeout_days)
      allow(SlackNotifierService).to receive(:call)
    end

    context "when timeout_after is nil" do
      context "during October" do
        let(:timeout_date) { trainee.submitted_for_trn_at + (configured_poll_timeout_days + 6).days }

        it "re-enqueues RetrieveTrnJob with the trainee and default timeout_after plus 6 days" do
          Timecop.travel(Time.zone.now.year, 10, 1) do
            expect {
              described_class.perform_now(trn_request, nil)
            }.to enqueue_job(RetrieveTrnJob).with(trn_request, timeout_date)
          end
        end
      end

      context "during any time of the year other than October" do
        let(:timeout_date) { trainee.submitted_for_trn_at + configured_poll_timeout_days.days }

        it "re-enqueues RetrieveTrnJob with the trainee and default timeout_after" do
          (1..9).to_a + [11, 12].each do |month|
            Timecop.travel(Time.zone.now.year, month, 1) do
              expect {
                described_class.perform_now(trn_request, nil)
              }.to enqueue_job(RetrieveTrnJob).with(trn_request, timeout_date)
            end
          end
        end
      end
    end

    context "when trainee already has a TRN" do
      let(:existing_trn) { "12345678" }
      let(:trainee) { create(:trainee, trn: existing_trn) }

      context "when trn_request is not in received state" do
        let(:trn_request) { create(:dqt_trn_request, trainee: trainee, state: :requested) }

        it "updates the trn_request to received state" do
          expect {
            described_class.perform_now(trn_request, timeout_date)
          }.to change { trn_request.reload.state }.from("requested").to("received")
        end

        it "doesn't call RetrieveTrn" do
          expect(RetrieveTrn).not_to receive(:call)
          described_class.perform_now(trn_request, timeout_date)
        end

        it "doesn't queue another job" do
          described_class.perform_now(trn_request, timeout_date)
          expect(RetrieveTrnJob).not_to have_been_enqueued
        end
      end

      context "when trn_request is already in received state" do
        let(:trn_request) { create(:dqt_trn_request, trainee: trainee, state: :received) }

        it "doesn't change the trn_request state" do
          expect {
            described_class.perform_now(trn_request, timeout_date)
          }.not_to change { trn_request.reload.state }
        end

        it "doesn't call RetrieveTrn" do
          expect(RetrieveTrn).not_to receive(:call)
          described_class.perform_now(trn_request, timeout_date)
        end

        it "doesn't queue another job" do
          described_class.perform_now(trn_request, timeout_date)
          expect(RetrieveTrnJob).not_to have_been_enqueued
        end
      end
    end

    context "TRN is available" do
      let(:trn) { "123" }

      it "updates the trainee TRN attribute" do
        expect {
          described_class.perform_now(trn_request, timeout_date)
        }.to change(trainee, :trn).to(trn)
      end

      it "doesn't queue another job" do
        described_class.perform_now(trn_request, timeout_date)
        expect(RetrieveTrnJob).not_to have_been_enqueued
      end
    end

    context "TRN is not available" do
      it "queues another job to fetch the TRN after the configured delay" do
        Timecop.freeze(Time.zone.now) do
          described_class.perform_now(trn_request, timeout_date)
          expect(RetrieveTrnJob).to have_been_enqueued.at(configured_delay.hours.from_now)
            .with(trn_request, timeout_date)
        end
      end
    end

    context "timeout_after has passed" do
      it "doesn't queue another job" do
        expect(SlackNotifierService).to receive(:call)
        described_class.perform_now(trn_request, 1.minute.ago)
        expect(RetrieveTrnJob).not_to have_been_enqueued
      end
    end

    context "the trainee attribute submitted_for_trn_at is nil" do
      let(:trainee) { create(:trainee, :submitted_for_trn, submitted_for_trn_at: nil) }
      let(:error_msg) { "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})" }

      it "raises a TraineeAttributeError" do
        expect {
          described_class.perform_now(trn_request, timeout_date)
        }.to raise_error(RetrieveTrnJob::TraineeAttributeError, error_msg)
      end
    end
  end
end
