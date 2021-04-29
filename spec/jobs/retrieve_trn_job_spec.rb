# frozen_string_literal: true

require "rails_helper"

describe RetrieveTrnJob do
  include ActiveJob::TestHelper

  let(:trn) { nil }
  let(:trainee) { create(:trainee, :submitted_for_trn) }

  before do
    allow(Dttp::RetrieveTrn).to receive(:call).with(trainee: trainee).and_return(trn)
  end

  context "TRN is available" do
    let(:trn) { "123" }

    it "updates the trainee TRN attribute" do
      expect {
        described_class.perform_now(trainee)
        trainee.reload
      }.to change(trainee, :trn).to(trn)
    end

    it "doesn't queue another job" do
      described_class.perform_now(trainee)
      expect(RetrieveTrnJob).to_not have_been_enqueued
    end
  end

  context "TRN is not available" do
    let(:configured_delay) { 6 }

    before do
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    end

    it "queues another job to fetch the TRN 6 hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee)
        expect(RetrieveTrnJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end
  end

  context "timing out after 4 days of polling" do
    let(:trainee) { create(:trainee, submitted_for_trn_at: configured_limit.days.ago) }
    let(:configured_limit) { 4 }

    before do
      allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_limit)
      allow(SlackNotifierService).to receive(:call)
    end

    it "doesn't queue another job after 4 days have passed without a TRN" do
      expect(SlackNotifierService).to receive(:call)
      described_class.perform_now(trainee)
      expect(RetrieveTrnJob).to_not have_been_enqueued
    end
  end

  context "the trainee attribute submitted_for_trn_at is nil" do
    let(:trainee) { create(:trainee) }
    let(:error_msg) { "Trainee#submitted_for_trn_at is nil - it should be timestamped (id: #{trainee.id})" }

    it "raises a TraineeAttributeError" do
      expect {
        described_class.perform_now(trainee)
      }.to raise_error(RetrieveTrnJob::TraineeAttributeError, error_msg)
    end
  end

  describe ".perform_with_default_delay" do
    let(:configured_delay) { 6 }

    before do
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    end

    it "queues the job to execute after the configured delay" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_with_default_delay(trainee)
        expect(RetrieveTrnJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end
  end
end
