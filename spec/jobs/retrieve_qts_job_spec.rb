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

    it "queues another job to fetch the QTS 6 hours from now" do
      Timecop.freeze(Time.zone.now) do
        described_class.perform_now(trainee)
        expect(RetrieveQtsJob).to have_been_enqueued.at(6.hours.from_now).with(trainee)
      end
    end

    context "after 2 days of polling" do
      let(:trainee) { create(:trainee, recommended_for_qts_at: 2.days.ago) }

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
end
