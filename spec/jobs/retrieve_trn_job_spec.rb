# frozen_string_literal: true

require "rails_helper"

describe RetrieveTrnJob do
  include ActiveJob::TestHelper

  let(:trn) { nil }
  let(:trainee) { create(:trainee, :trn_requested) }

  before do
    allow(Dttp::RetrieveTrn).to receive(:call).with(trainee: trainee).and_return(trn)
  end

  context "TRN is available" do
    let(:trn) { "123" }

    it "updates the trainee TRN attribute" do
      expect {
        described_class.perform_now(trainee.id)
        trainee.reload
      }.to change(trainee, :trn).to(trn)
    end

    it "doesn't queue another job" do
      described_class.perform_now(trainee.id)
      expect(RetrieveTrnJob).to_not have_been_enqueued
    end
  end

  context "TRN is not available" do
    it "queues another job to fetch the TRN 6 hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee.id)
        expect(RetrieveTrnJob).to have_been_enqueued.at(6.hours.from_now).with(trainee.id)
      end
    end

    context "after 2 days of polling" do
      let(:trainee) { create(:trainee, trn_requested_at: 2.days.ago) }

      it "doesn't queue another job after 2 days have passed without a TRN" do
        described_class.perform_now(trainee.id)
        expect(RetrieveTrnJob).to_not have_been_enqueued
      end
    end
  end

  context "the trainee attribute trn_requested_at is nil" do
    let(:trainee) { create(:trainee) }
    let(:error_msg) { "Trainee#trn_requested_at is nil - it should be timestamped (id: #{trainee.id})" }

    it "raises a TraineeAttributeError" do
      expect {
        described_class.perform_now(trainee.id)
      }.to raise_error(RetrieveTrnJob::TraineeAttributeError, error_msg)
    end
  end
end
