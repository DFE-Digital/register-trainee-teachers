# frozen_string_literal: true

require "rails_helper"

describe RetrieveAwardJob do
  include ActiveJob::TestHelper

  let(:award_flag) { nil }
  let(:trainee) { create(:trainee, :recommended_for_award) }
  let(:configured_delay) { 6 }
  let(:configured_poll_timeout_days) { 4 }
  let(:timeout_date) { configured_poll_timeout_days.days.from_now }

  before do
    allow(Dttp::RetrieveAward).to receive(:call).with(trainee: trainee).and_return(award_flag)
    allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_poll_timeout_days)
    allow(SlackNotifierService).to receive(:call)
  end

  context "when timeout_after is nil" do
    let(:timeout_date) { trainee.recommended_for_award_at + configured_poll_timeout_days.days }

    it "reenqueues RetrieveAwardJob with the trainee and default timeout_after" do
      Timecop.freeze(Time.zone.now) do
        expect {
          described_class.perform_now(trainee, nil)
        }.to enqueue_job(RetrieveAwardJob).with(trainee, timeout_date)
      end
    end
  end

  context "Award is awarded in DTTP" do
    let(:award_flag) { true }

    it "transitions the trainee to awarded" do
      expect {
        described_class.perform_now(trainee, timeout_date)
        trainee.reload
      }.to change(trainee, :state).to("awarded")
    end

    it "doesn't queue another job" do
      described_class.perform_now(trainee, timeout_date)
      expect(RetrieveAwardJob).not_to have_been_enqueued
    end
  end

  context "Award is not awarded in DTTP" do
    let(:award_flag) { false }

    it "queues another job to fetch the Award the configured number of hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee, timeout_date)
        expect(RetrieveAwardJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee, timeout_date)
      end
    end

    context "timeout_after has passed" do
      it "doesn't queue another job" do
        expect(SlackNotifierService).to receive(:call)
        described_class.perform_now(trainee, Time.zone.now - 1.minute)
        expect(RetrieveAwardJob).not_to have_been_enqueued
      end
    end
  end

  context "the trainee attribute recommended_for_award_at is nil" do
    let(:trainee) { create(:trainee) }
    let(:error_msg) { "Trainee#recommended_for_award_at is nil - it should be timestamped (id: #{trainee.id})" }

    it "raises a TraineeAttributeError" do
      expect {
        described_class.perform_now(trainee, timeout_date)
      }.to raise_error(RetrieveAwardJob::TraineeAttributeError, error_msg)
    end
  end

  describe ".perform_with_default_delay" do
    it "enqueues the job with the configured delay" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee, timeout_date)
        expect(RetrieveAwardJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee, timeout_date)
      end
    end
  end
end
