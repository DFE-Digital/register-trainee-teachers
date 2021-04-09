# frozen_string_literal: true

require "rails_helper"

describe RetrieveQtsJob do
  include ActiveJob::TestHelper

  let(:qts_flag) { nil }
  let(:trainee) { create(:trainee, :recommended_for_qts) }

  before do
    allow(Dttp::RetrieveQts).to receive(:call).with(trainee: trainee).and_return(qts_flag)
  end

  context "QTS is awarded in DTTP" do
    let(:qts_flag) { true }

    it "transitions the trainee to qts_awarded" do
      expect {
        described_class.perform_now(trainee)
        trainee.reload
      }.to change(trainee, :state).to("qts_awarded")
    end

    it "doesn't queue another job" do
      described_class.perform_now(trainee)
      expect(RetrieveQtsJob).to_not have_been_enqueued
    end
  end

  context "QTS is not awarded in DTTP" do
    let(:qts_flag) { false }
    let(:configured_delay) { 6 }

    before do
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    end

    it "queues another job to fetch the QTS the configured number of hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee)
        expect(RetrieveQtsJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end

    context "after the configured days of polling" do
      let(:trainee) { create(:trainee, recommended_for_qts_at: configured_limit.days.ago) }
      let(:configured_limit) { 2 }

      before do
        allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_limit)
      end

      it "doesn't queue another job after 2 days have passed with no QTS" do
        described_class.perform_now(trainee)
        expect(RetrieveQtsJob).to_not have_been_enqueued
      end
    end
  end

  context "the trainee attribute recommended_for_qts_at is nil" do
    let(:trainee) { create(:trainee) }
    let(:error_msg) { "Trainee#recommended_for_qts_at is nil - it should be timestamped (id: #{trainee.id})" }

    it "raises a TraineeAttributeError" do
      expect {
        described_class.perform_now(trainee)
      }.to raise_error(RetrieveQtsJob::TraineeAttributeError, error_msg)
    end
  end

  describe ".perform_with_default_delay" do
    let(:configured_delay) { 6 }

    before do
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    end

    it "enqueues the job with the configured delay" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee)
        expect(RetrieveQtsJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end
  end
end
