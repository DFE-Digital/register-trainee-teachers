# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RetrieveTrnJob do
    include ActiveJob::TestHelper

    let(:trn) { nil }
    let(:trainee) { create(:trainee, :submitted_for_trn) }
    let(:configured_delay) { 6 }
    let(:configured_poll_timeout_days) { 4 }
    let(:timeout_date) { configured_poll_timeout_days.days.from_now }
    let(:trn_request) { create(:dqt_trn_request, trainee: trainee) }

    before do
      enable_features(:integrate_with_dqt)
      allow(RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_return(trn)
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
      allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_poll_timeout_days)
      allow(SlackNotifierService).to receive(:call)
    end

    context "when timeout_after is nil" do
      let(:timeout_date) { trainee.submitted_for_trn_at + configured_poll_timeout_days.days }

      it "re-enqueues RetrieveTrnJob with the trainee and default timeout_after" do
        Timecop.freeze(Time.zone.now) do
          expect {
            described_class.perform_now(trn_request, nil)
          }.to enqueue_job(RetrieveTrnJob).with(trn_request, timeout_date)
        end
      end
    end

    context "TRN is available" do
      let(:trn) { "123" }

      it "updates the trainee TRN attribute" do
        expect {
          described_class.perform_now(trn_request, timeout_date)
          trainee.reload
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

    context "time_out after has passed" do
      it "doesn't queue another job" do
        expect(SlackNotifierService).to receive(:call)
        described_class.perform_now(trn_request, Time.zone.now - 1.minute)
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
