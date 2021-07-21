# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveTrnJob do
    include ActiveJob::TestHelper

    let(:trn) { nil }
    let(:trainee) { create(:trainee, :submitted_for_trn) }
    let(:configured_delay) { 6 }
    let(:configured_poll_timeout_days) { 4 }
    let(:timeout_date) { configured_poll_timeout_days.days.from_now }

    let(:run_date) { "01/08/2021" }
    let(:clockover_date) { "01/08/2021" }

    around do |example|
      Timecop.freeze(run_date) do
        example.run
      end
    end

    before do
      allow(RetrieveTrn).to receive(:call).with(trainee: trainee).and_return(trn)
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
      allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_poll_timeout_days)
      allow(SlackNotifierService).to receive(:call)
      allow(Settings).to receive(:clockover_date).and_return(clockover_date)
    end

    context "when timeout_after is nil" do
      let(:timeout_date) { trainee.submitted_for_trn_at + configured_poll_timeout_days.days }

      it "re-enqueues RetrieveTrnJob with the trainee and default timeout_after" do
        expect {
          described_class.perform_now(trainee, nil)
        }.to enqueue_job(RetrieveTrnJob).with(trainee, timeout_date)
      end
    end

    context "TRN is available" do
      let(:trn) { "123" }

      it "updates the trainee TRN attribute" do
        expect {
          described_class.perform_now(trainee, timeout_date)
          trainee.reload
        }.to change(trainee, :trn).to(trn)
      end

      it "doesn't queue another job" do
        described_class.perform_now(trainee, timeout_date)
        expect(RetrieveTrnJob).not_to have_been_enqueued
      end
    end

    context "TRN is not available" do
      it "queues another job to fetch the TRN after the configured delay" do
        described_class.perform_now(trainee, timeout_date)
        expect(RetrieveTrnJob).to have_been_enqueued.at(configured_delay.hours.from_now)
          .with(trainee, timeout_date)
      end
    end

    context "time_out after has passed" do
      it "doesn't queue another job" do
        expect(SlackNotifierService).to receive(:call)
        described_class.perform_now(trainee, Time.zone.now - 1.minute)
        expect(RetrieveTrnJob).not_to have_been_enqueued
      end
    end

    context "the trainee attribute submitted_for_trn_at is nil" do
      let(:trainee) { create(:trainee) }
      let(:error_msg) { "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})" }

      it "raises a TraineeAttributeError" do
        expect {
          described_class.perform_now(trainee, timeout_date)
        }.to raise_error(RetrieveTrnJob::TraineeAttributeError, error_msg)
      end
    end

    describe ".perform_with_default_delay" do
      it "queues the job to execute after the configured delay" do
        described_class.perform_with_default_delay(trainee)
        expect(RetrieveTrnJob).to have_been_enqueued.at(configured_delay.hours.from_now)
          .with(trainee, configured_poll_timeout_days.day.from_now)
      end
    end

    context "before clockover" do
      let(:run_date) { "31/07/2021" }

      context "trainee is not assessment only" do
        before do
          trainee.provider_led_postgrad!
        end

        it "requeues the job after clockover" do
          clockover_date_as_time = Time.zone.parse(clockover_date)
          expect(RetrieveTrnJob).to receive(:set).with(wait_until: clockover_date_as_time).and_return(job = double)
          expect(job).to receive(:perform_later).with(trainee, clockover_date_as_time + configured_poll_timeout_days.days)
          described_class.perform_now(trainee, timeout_date)
        end
      end

      context "trainee is assessment only" do
        before do
          trainee.assessment_only!
        end

        it "runs the job" do
          expect(RetrieveTrn).to receive(:call)
          described_class.perform_now(trainee, timeout_date)
        end
      end
    end
  end
end
