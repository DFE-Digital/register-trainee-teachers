# frozen_string_literal: true

require "rails_helper"

describe RetrieveAwardJob do
  include ActiveJob::TestHelper

  let(:award_flag) { nil }
  let(:trainee) { create(:trainee, :recommended_for_award) }

  before do
    allow(Dttp::RetrieveAward).to receive(:call).with(trainee: trainee).and_return(award_flag)
  end

  context "Award is awarded in DTTP" do
    let(:award_flag) { true }

    it "transitions the trainee to awarded" do
      expect {
        described_class.perform_now(trainee)
        trainee.reload
      }.to change(trainee, :state).to("awarded")
    end

    it "doesn't queue another job" do
      described_class.perform_now(trainee)
      expect(RetrieveAwardJob).to_not have_been_enqueued
    end
  end

  context "Award is not awarded in DTTP" do
    let(:award_flag) { false }
    let(:configured_delay) { 6 }

    before do
      allow(Settings.jobs).to receive(:poll_delay_hours).and_return(configured_delay)
    end

    it "queues another job to fetch the Award the configured number of hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee)
        expect(RetrieveAwardJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end

    context "timing out after after 4 days of polling" do
      let(:trainee) { create(:trainee, recommended_for_award_at: configured_limit.days.ago) }
      let(:configured_limit) { 4 }

      before do
        allow(Settings.jobs).to receive(:max_poll_duration_days).and_return(configured_limit)
        allow(SlackNotifierService).to receive(:call)
      end

      it "doesn't queue another job after 4 days have passed with no QTS" do
        expect(SlackNotifierService).to receive(:call)
        described_class.perform_now(trainee)
        expect(RetrieveAwardJob).to_not have_been_enqueued
      end
    end
  end

  context "the trainee attribute recommended_for_award_at is nil" do
    let(:trainee) { create(:trainee) }
    let(:error_msg) { "Trainee#recommended_for_award_at is nil - it should be timestamped (id: #{trainee.id})" }

    it "raises a TraineeAttributeError" do
      expect {
        described_class.perform_now(trainee)
      }.to raise_error(RetrieveAwardJob::TraineeAttributeError, error_msg)
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
        expect(RetrieveAwardJob).to have_been_enqueued.at(configured_delay.hours.from_now).with(trainee)
      end
    end
  end
end
